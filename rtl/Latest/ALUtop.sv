module ALUtop #(
    parameter A_WIDTH = 5,
    D_WIDTH = 32
) (
    input  logic               CLK,
    input  logic               trigger,
    input  logic               Jump,
    input  logic               ALUSrc,
    input  logic [        3:0] ALUControl,
    input  logic               RegWrite,
    input  logic               PCUppSrc,
    input  logic               ImmUppSrc,
    input  logic [A_WIDTH-1:0] A1,
    input  logic [A_WIDTH-1:0] A2,
    input  logic [A_WIDTH-1:0] A3,
    input  logic [D_WIDTH-1:0] PC,
    input  logic [D_WIDTH-1:0] ImmExt,
    input  logic [D_WIDTH-1:0] Result,
    output logic               Zero,
    output logic [D_WIDTH-1:0] ALUResult,
    output logic [D_WIDTH-1:0] RD2,
    output logic [D_WIDTH-1:0] a0
);

  // Internal Signals
  logic [D_WIDTH-1:0] SrcA;
  logic [D_WIDTH-1:0] SrcB;
  logic [D_WIDTH-1:0] RD1;
  logic [D_WIDTH-1:0] ImmRes;
  logic [D_WIDTH-1:0] WD3;

  //WD3 MUX's
  always_comb begin
    ImmRes = ImmUppSrc ? ImmExt : Result;
    WD3 = Jump ? PC + 4 : ImmRes;
  end

  // Reg File Module
  RegisterFile RF (
      .CLK(CLK),
      .trigger(trigger),
      .WE3(RegWrite),
      .A1 (A1),
      .A2 (A2),
      .A3 (A3),
      .WD3(WD3),
      .RD1(RD1),
      .RD2(RD2),
      .a0 (a0)
  );

  // SrcA MUX
  assign SrcA = PCUppSrc ? PC + 4 : RD1;

  // SrcB MUX 
  assign SrcB = ALUSrc ? ImmExt : RD2;

  // ALU Module
  ALU ALU (
      .ALUControl(ALUControl),
      .SrcA(SrcA),
      .SrcB(SrcB),
      .ALUResult(ALUResult),
      .Zero(Zero)
  );

endmodule

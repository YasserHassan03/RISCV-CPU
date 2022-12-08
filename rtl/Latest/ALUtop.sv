module ALUtop #(
    parameter A_WIDTH = 5,
    D_WIDTH = 32
) (
    input  logic               CLK,
    input  logic               ALUSrc,
    input  logic [        2:0] ALUControl,
    input  logic               RegWrite,
    input  logic [A_WIDTH-1:0] A1,
    input  logic [A_WIDTH-1:0] A2,
    input  logic [A_WIDTH-1:0] A3,
    input  logic [D_WIDTH-1:0] ImmExt,
    input  logic               ResultSrc,
    input  logic               MemWrite,
    output logic               Zero,
    output logic [D_WIDTH-1:0] a0
);

  // Internal Wires
  logic [D_WIDTH-1:0] SrcA;
  logic [D_WIDTH-1:0] SrcB;
  logic [D_WIDTH-1:0] WriteData;
  logic [D_WIDTH-1:0] ALUResult;
  logic [D_WIDTH-1:0] ReadData;
  logic [D_WIDTH-1:0] Result;

  // Reg File Module
  RegFile rf (
      .CLK(CLK),
      .WE3(RegWrite),
      .A1 (A1),
      .A2 (A2),
      .A3 (A3),
      .WD3(Result),
      .RD1(SrcA),
      .RD2(WriteData),
      .a0 (a0)
  );

  // MUX 
  assign SrcB = ALUSrc ? ImmExt : WriteData;

  // ALU Module
  ALU alu (
      .ALUControl(ALUControl),
      .SrcA(SrcA),
      .SrcB(SrcB),
      .ALUResult(ALUResult),
      .Zero(Zero)
  );

  DataMemory dm (
      .A  (ALUResult),
      .WD (WriteData),
      .WE (MemWrite),
      .RD (ReadData),
      .CLK(CLK)
  );

  always_comb begin
    assign Result = ResultSrc ? ReadData : ALUResult;
    $display("Result: ", Result);
  end

endmodule

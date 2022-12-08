module PCtop #(
    parameter D_WIDTH = 32
) (
    input logic CLK,
    input logic rst,
    input logic PCSrc,
    input logic JumpReg,
    input logic [D_WIDTH-1:0] Result,
    input logic [D_WIDTH-1:0] ImmExt,
    output logic [D_WIDTH-1:0] PC
);

  // Internal Wires
  logic [D_WIDTH-1:0] PCTarget;
  logic [D_WIDTH-1:0] PCNext;
  logic [D_WIDTH-1:0] PCPlus4;
  logic [D_WIDTH-1:0] PCInterm;

  // MUX Logic 
  always_comb begin
    PCPlus4  = PC + 4;
    PCTarget = PC + ImmExt;
    PCInterm = PCSrc ? PCTarget : PCPlus4;
    PCNext   = JumpReg ? Result : PCInterm;
  end

  // DFF Module
  PCReg PCR (
      .CLK(CLK),
      .rst(rst),
      .PCNext(PCNext),
      .PC(PC)
  );

endmodule

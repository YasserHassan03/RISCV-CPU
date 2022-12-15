module PCtop #(
    parameter D_WIDTH = 32
) (
    input logic CLK,
    input logic rst,
    input logic PCSrc,
    input logic JumpReg,
    input logic [D_WIDTH-1:0] PCTarget,
    input logic [D_WIDTH-1:0] Result,
    output logic [D_WIDTH-1:0] PCPlus4,
    output logic [D_WIDTH-1:0] PC
);

  // Internal Wires
  logic [D_WIDTH-1:0] PCNext;
  logic [D_WIDTH-1:0] PCInterm;

  // MUX Logic 
  always_comb begin
    PCPlus4  = PC + 4;
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

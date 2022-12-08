module PCtop #(
    parameter D_WIDTH = 32
) (
    input logic CLK,
    input logic rst,
    input logic PCSrc,
    input logic [D_WIDTH-1:0] ImmExt,
    output logic [D_WIDTH-1:0] PC
);

  // Internal Wires
  logic [D_WIDTH-1:0] PCTarget;
  logic [D_WIDTH-1:0] PCPlus4;
  logic [D_WIDTH-1:0] PCNext;

  // Combinational Logic
  always_comb begin
    PCPlus4  = PC + 4;
    PCTarget = PC + ImmExt;
    PCNext   = PCSrc ? PCTarget : PCPlus4;
  end

  // DFF Module
  PCReg PCR (
      .CLK(CLK),
      .rst(rst),
      .PCNext(PCNext),
      .PC(PC)
  );

endmodule

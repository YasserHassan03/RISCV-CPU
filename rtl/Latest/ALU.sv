module ALU #(
    parameter D_WIDTH = 32
) (
    input  logic [        2:0] ALUControl,
    input  logic [D_WIDTH-1:0] SrcA,
    input  logic [D_WIDTH-1:0] SrcB,
    output logic [D_WIDTH-1:0] ALUResult,
    output logic               Zero
);

  always_comb begin
    Zero = (SrcA == SrcB);
    case (ALUControl)
      3'b000:  ALUResult = SrcA + SrcB;  // Add
      3'b001:  ALUResult = SrcA - SrcB;  // Sub
      3'b010:  ALUResult = SrcA & SrcB;  // And
      3'b011:  ALUResult = SrcA | SrcB;  // OR
      3'b100:  ALUResult = SrcA ^ SrcB;  // XOR
      3'b101:  ALUResult = {{31{1'b0}}, {SrcA < SrcB}};  // SLT
      3'b110:  ALUResult = SrcA << SrcB;  // Shift Left
      3'b111:  ALUResult = SrcA >> SrcB;  // Shift Right
      default: ALUResult = 32'b0;  // Default
    endcase
    $display("ALU1", SrcA);
    $display("ALU2", SrcB);
  end

endmodule

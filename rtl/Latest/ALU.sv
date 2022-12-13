module ALU #(
    parameter D_WIDTH = 32
) (
    input  logic [        3:0] ALUControl,
    input  logic [D_WIDTH-1:0] SrcA,
    input  logic [D_WIDTH-1:0] SrcB,
    output logic [D_WIDTH-1:0] ALUResult,
    output logic               Zero
);

  always_comb begin
    case (ALUControl[2:0])
      // Add Sub
      3'b000:  ALUResult = ALUControl[3] ? SrcA - SrcB : SrcA + SrcB;
      // Shift Left    
      3'b001:  ALUResult = SrcA << SrcB[4:0];
      // Set Less Than (Signed) 
      3'b010:  ALUResult = {{31{1'b0}}, {signed'(SrcA) < signed'(SrcB)}};
      // Set Less Than (Unsigned)
      3'b011:  ALUResult = {{31{1'b0}}, {SrcA < SrcB}};
      // XOR
      3'b100:  ALUResult = SrcA ^ SrcB;
      // Shift Right (Arithmetic/Logical) 
      3'b101:  ALUResult = ALUControl[3] ? $signed($signed(SrcA) >>> SrcB[4:0]) : SrcA >> SrcB[4:0];
      // OR 
      3'b110:  ALUResult = SrcA | SrcB;
      // AND
      3'b111:  ALUResult = SrcA & SrcB;
      // Default
      default: ALUResult = 32'b0;
    endcase
    Zero = (ALUResult == 0);
  end

endmodule

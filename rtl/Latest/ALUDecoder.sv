module ALUDecoder (
    input  logic [1:0] ALUOp,
    input  logic       op5,
    input  logic [2:0] funct3,
    input  logic       funct7,
    output logic [2:0] Type,
    output logic [3:0] ALUControl
);

  always_comb begin
    Type = 3'b111;
    case (ALUOp)
      // Load Store 
      2'b00: begin
        ALUControl = 4'b0000;
        Type = funct3;
      end
      // Branch (bne/beq = 0000, blt/bge = 0010, bltu/bgeu = 0011)
      2'b01:   ALUControl = funct3[2] ? {{3'b001}, {funct3[1]}} : 4'b0000;
      // ALU bit 3 only matters for add/sub vs rsl/rsa so we can us funct3[2] to determine it
      2'b10:   ALUControl = {{funct3[2] ? {funct7} : {funct7 & op5}}, {funct3}};
      // Default
      default: ALUControl = 4'b0000;
    endcase
  end

endmodule

module ALUDecoder (
    input  logic [1:0] ALUOp,
    input  logic       op5,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [2:0] ALUControl
);

  always_comb begin
    case (ALUOp)
      // Load Store
      2'b00: ALUControl = 3'b000;
      // Branch 
      2'b01:
      case (funct3)
        // Branch Equal - beq
        3'b00:   ALUControl = 3'b001;
        // Branch Not Equal - bne
        3'b01:   ALUControl = 3'b001;
        // Other Branches maybe use slt aluctrl
        default: ALUControl = 3'b001;
      endcase
      // ALU
      2'b10:
      case (funct3)
        // Add Sub - add, sub
        3'b000:
        case ({{op5},{funct7[5]}})
          // Sub - sub
          2'b11:   ALUControl = 3'b001;
          // Add - add                                                                                        
          default: ALUControl = 3'b000;
        endcase
        // Shift Left
        3'b001: ALUControl = 3'b110;
        // Set Less Than - slt 
        3'b010: ALUControl = 3'b101;
        // Set Less Than Unsigned - sltu
        3'b011: ALUControl = 3'b101;  // CHANGE
        // XOR
        3'b100: ALUControl = 3'b100;
        // Right Shift
        3'b101:
        case (funct7[5])
          1'b0: ALUControl = 3'b111;
          // NEEDS CHANGING FOR ARITHMETIC SHIFT
          1'b1: ALUControl = 3'b111;  // CHANGE
        endcase
        // Or - or
        3'b110: ALUControl = 3'b011;
        // And - and
        3'b111: ALUControl = 3'b010;
        // Default 
        default: ALUControl = 3'b111;
      endcase
      // Default
      default: ALUControl = 3'b111;
    endcase
  end

endmodule

module SignExtend (
    input  logic [31:7] Imm,
    input  logic [ 2:0] ImmSrc,
    output logic [31:0] ImmExt
);

  always_comb
    case (ImmSrc)
      // Signed Immediate
      3'b000:  ImmExt = {{20{Imm[31]}}, {Imm[31:20]}};
      // Upper Immediate
      3'b001:  ImmExt = {{Imm[31:12]}, {12{1'b0}}};
      // Store
      3'b010:  ImmExt = {{20{Imm[31]}}, {Imm[31:25]}, {Imm[11:7]}};
      // Branch
      3'b011:  ImmExt = {{20{Imm[31]}}, {Imm[7]}, {Imm[30:25]}, {Imm[11:8]}, {1'b0}};
      // Jump      
      3'b100:  ImmExt = {{12{Imm[31]}}, {Imm[19:12]}, {Imm[20]}, {Imm[30:21]}, {1'b0}};
      // Unsigned Imm
      //    3'b101   ImmExt = {{20{1'b0}},{Imm[31:20]}};
      // Default
      default: ImmExt = {32{1'b0}};
    endcase

endmodule

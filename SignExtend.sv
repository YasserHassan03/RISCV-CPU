module SignExtend(
    input  logic [31:7] Instr,
    input  logic [2:0]  ImmSrc,
    output logic [31:0] ImmExt
);

    always_comb 
        case (ImmSrc)
        // Immediate
            3'b000:  ImmExt = {{20{Instr[31]}},{Instr[31:20]}};
        // Upper Immediate
            3'b001:  ImmExt = {{Instr[31:12]},{12{1'b0}}}; 
        // Store
            3'b010:  ImmExt = {{20{Instr[31]}},{Instr[31:25]},{Instr[11:7]}};
        // Branch
            3'b011:  ImmExt = {{21{Instr[31]}},{Instr[7]},{Instr[30:25]},{Instr[11:8]}};
        // Jump      
            3'b100:  ImmExt = {{13{Instr[31]}},{Instr[19:12]},{Instr[20]},{Instr[30:21]}};
        // Default
            default: ImmExt = {32{1'b0}};
        endcase
    
endmodule

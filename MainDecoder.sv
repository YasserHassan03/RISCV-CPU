module MainDecoder(
    input  logic [6:0] op,
    output logic       Branch,
    output logic       ResultSrc,
    output logic       MemWrite,
    output logic       ALUSrc,
    output logic [2:0] ImmSrc,
    output logic       RegWrite,
    output logic [1:0] ALUOp
);

    always_comb begin
        // Set Defaults
        Branch    = 1'b0;
        ResultSrc = 1'b0;
        MemWrite  = 1'b0; 
        ALUSrc    = 1'b1; 
        ImmSrc    = 3'b111; 
        RegWrite  = 1'b0;
        ALUOp     = 2'b00; 

        case (op)
        // Register - R
            
            7'd51: begin //case (funct7) // Register format endcase
            //     default: $display ("Invalid Instruction");
            // endcase
                RegWrite  = 1'b1;
                ALUSrc    = 1'b0;
                ALUOp     = 2'b10;
            end
        // Immediate - I
            // Load Word
            7'd03: begin 
                    RegWrite  = 1'b1;
                    ImmSrc    = 3'b000;
                    ResultSrc = 1'b1;
                    ALUOp     = 2'b00; 
            end
            // Immediate Logic
            7'd19: begin
                RegWrite  = 1'b1;
                ImmSrc    = 3'b000;
                ALUOp     = 2'b10;
            end
        // Upper Immediate - UI
            // 7'd23: // Add  Upper Immediate to PC
            // 7'd55: // Load Upper Immediate
        // Store - S
            7'd35: begin// Store Immediate
                ImmSrc   = 3'b010;
                ALUSrc   = 1'b0;
                MemWrite = 1'b1; 
            end              
        // Branch - B         
            7'd99: begin
                ImmSrc = 3'b011; 
                ALUSrc = 1'b0; 
                Branch = 1'b1;
            end
        // Jump - J
            // 7'd103: begin // Jump and link register
            // end 
            // 7'd111: begin // Jump and link 
            // end
        // Invalid 
            default: $display ("Invalid Instruction");
        endcase

    end


endmodule

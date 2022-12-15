module MainDecoder (
    input  logic [6:0] op,
    output logic       RegWrite,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic       Jump,
    output logic       JumpReg,
    output logic       Branch,
    output logic [1:0] ALUOp,
    output logic       ALUSrc,
    output logic [2:0] ImmSrc,
    output logic       RD1Src
);

  // Control Logic
  always_comb begin
    // Set Defaults
    RegWrite  = 1'b0;
    ResultSrc = 2'b00;
    MemWrite  = 1'b0;
    Jump      = 1'b0;
    JumpReg   = 1'b0;
    Branch    = 1'b0;
    ALUOp     = 2'b11;
    ALUSrc    = 1'b1;
    ImmSrc    = 3'b111;
    RD1Src    = 1'b0;

    case (op)
    // Register - R
      // Register Instructions
      7'd51: begin
        RegWrite  = 1'b1;
        ALUSrc    = 1'b0;
        ALUOp     = 2'b10;
      end        
    // Immediate - I
      // Load Instructions
      7'd03: begin
        ResultSrc = 2'b01;
        RegWrite  = 1'b1;
        ImmSrc    = 3'b000;
        ALUOp     = 2'b00;
      end
      // Immediate Instructions
      7'd19: begin
        RegWrite  = 1'b1;
        ImmSrc    = 3'b000;
        ALUOp     = 2'b10;
      end
    // Upper Immediate - UI
      // Add Upper Immediate and PC to Reg
      7'd23: begin
        ImmSrc    = 3'b001;
        RegWrite  = 1'b1;
        RD1Src    = 1'b1;
      end
      // Load Upper Immediate to Reg
      7'd55: begin
        ImmSrc    = 3'b001;
        RegWrite  = 1'b1;
        ResultSrc = 2'b11;
      end
    // Store - S
      // Store Instructons
      7'd35: begin
        ALUOp     = 2'b00;
        ImmSrc    = 3'b010;
        MemWrite  = 1'b1;
      end
    // Branch - B   
      // Branch Instructions    
      7'd99: begin
        ImmSrc    = 3'b011;
        ALUOp     = 2'b01;
        ALUSrc    = 1'b0;
        Branch    = 1'b1;
      end
    // Jump - J
      // Jump and link register
      7'd103: begin
        ResultSrc = 2'b10;
        JumpReg   = 1'b1;
        ImmSrc    = 3'b000;
        RegWrite  = 1'b1;
      end
      // Jump and link 
      7'd111: begin
        ResultSrc = 2'b10;
        Jump      = 1'b1;
        ImmSrc    = 3'b100;
        RegWrite  = 1'b1;
      end
    // Invalid 
      default: ;
    endcase
  end

endmodule

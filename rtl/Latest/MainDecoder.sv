module MainDecoder (
    input  logic [6:0] op,
    output logic       Branch,
    output logic       Jump,
    output logic       JumpReg,
    output logic       ResultSrc,
    output logic       MemWrite,
    output logic       ALUSrc,
    output logic [2:0] ImmSrc,
    output logic       RegWrite,
    output logic [1:0] ALUOp,
    output logic       PCUppSrc,
    output logic       ImmUppSrc
);

  // Control Logic
  always_comb begin
    // Set Defaults
    Jump      = 1'b0;
    JumpReg   = 1'b0;
    Branch    = 1'b0;
    ResultSrc = 1'b0;
    MemWrite  = 1'b0;
    ALUSrc    = 1'b1;
    ImmSrc    = 3'b111;
    RegWrite  = 1'b0;
    ALUOp     = 2'b11;
    PCUppSrc  = 1'b0;
    ImmUppSrc = 1'b0;

    case (op)
    // Register - R
      // Register Instructions
      7'd51: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b0;
        ALUOp    = 2'b10;
      end
    // Immediate - I
      // Load Instructions
      7'd03: begin
        RegWrite  = 1'b1;
        ImmSrc    = 3'b000;
        ResultSrc = 1'b1;
        ALUOp     = 2'b00;
      end
      // Immediate Instructions
      7'd19: begin
        RegWrite = 1'b1;
        ImmSrc   = 3'b000;
        ALUOp    = 2'b10;
      end
    // Upper Immediate - UI
      // Add Upper Immediate and PC to Reg
      7'd23: begin
        ImmSrc   = 3'b001;
        RegWrite = 1'b1;
        PCUppSrc = 1'b1;
      end
      // Load Upper Immediate to Reg
      7'd55: begin
        ImmSrc    = 3'b001;
        RegWrite  = 1'b1;
        ImmUppSrc = 1'b1;
      end
    // Store - S
      // Store Instructons
      7'd35: begin
        ImmSrc   = 3'b010;
        ALUSrc   = 1'b0;
        MemWrite = 1'b1;
      end
    // Branch - B   
      // Branch Instructions    
      7'd99: begin
        ImmSrc = 3'b011;
        ALUOp  = 2'b01;
        ALUSrc = 1'b0;
        Branch = 1'b1;
      end
    // Jump - J
      // Jump and link register
      7'd103: begin
        Jump     = 1'b1;
        JumpReg  = 1'b1;
        ImmSrc   = 3'b000;
        RegWrite = 1'b1;
      end
      // Jump and link 
      7'd111: begin
        Jump     = 1'b1;
        ImmSrc   = 3'b100;
        RegWrite = 1'b1;
      end
    // Invalid 
      default: $display("Invalid Instruction");
    endcase
  end

endmodule

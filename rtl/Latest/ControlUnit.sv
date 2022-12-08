module ControlUnit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7,
    input  logic       Zero,
    output logic       Jump,
    output logic       JumpReg,
    output logic       PCSrc,
    output logic       ResultSrc,
    output logic [2:0] Type,
    output logic       MemWrite,
    output logic [3:0] ALUControl,
    output logic       ALUSrc,
    output logic [2:0] ImmSrc,
    output logic       RegWrite,
    output logic       PCUppSrc,
    output logic       ImmUppSrc
);


  // Internal Signals
  logic [1:0] ALUOp;
  logic       Branch;

  // Main Decoder
  MainDecoder MD (
      .op(op),
      .Branch(Branch),
      .Jump(Jump),
      .JumpReg(JumpReg),
      .ResultSrc(ResultSrc),
      .MemWrite(MemWrite),
      .ALUSrc(ALUSrc),
      .ImmSrc(ImmSrc),
      .RegWrite(RegWrite),
      .ALUOp(ALUOp),
      .PCUppSrc(PCUppSrc),
      .ImmUppSrc(ImmUppSrc)
  );

  // ALU Decoder
  ALUDecoder AD (
      .ALUOp(ALUOp),
      .op5(op[5]),
      .funct3(funct3),
      .funct7(funct7),
      .Type(Type),
      .ALUControl(ALUControl)
  );

  // Assigns PCSrc
  assign PCSrc = (Branch & (funct3[0] ^ Zero)) || Jump;

endmodule

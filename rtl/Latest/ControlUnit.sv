module ControlUnit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7,
    output logic       RegWrite,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic       Jump,
    output logic       JumpReg,
    output logic [2:0] Type,
    output logic       Branch,
    output logic [3:0] ALUControl,
    output logic       ALUSrc,
    output logic [2:0] ImmSrc,
    output logic       RD1Src
);

  // Internal Signals
  logic [1:0] ALUOp;

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
      .RD1Src(RD1Src)
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

endmodule

module ControlUnit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    input  logic       Zero,
    output logic       PCSrc,
    output logic       ResultSrc,
    output logic       MemWrite,
    output logic [2:0] ALUControl,
    output logic       ALUSrc,
    output logic [2:0] ImmSrc,
    output logic       RegWrite
);

  logic [1:0] ALUOp;
  logic       Branch;

  MainDecoder MD (
      .op(op),
      .Branch(Branch),
      .ResultSrc(ResultSrc),
      .MemWrite(MemWrite),
      .ALUSrc(ALUSrc),
      .ImmSrc(ImmSrc),
      .RegWrite(RegWrite),
      .ALUOp(ALUOp)
  );

  ALUDecoder AD (
      .ALUOp(ALUOp),
      .op5(op[5]),
      .funct3(funct3),
      .funct7(funct7),
      .ALUControl(ALUControl)
  );

  assign PCSrc = Branch & (funct3[0] ^ Zero);

endmodule

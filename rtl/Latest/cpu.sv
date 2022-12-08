module cpu #(
    parameter WIDTH = 32
) (
    input  logic CLK,
    input  logic trigger,
    input  logic rst,
    output logic [WIDTH-1:0] a0
);

  // Internal Wires   
  logic [WIDTH-1:0] PC;
  logic [WIDTH-1:0] Instr;
  logic [WIDTH-1:0] ImmExt;
  logic [WIDTH-1:0] ALUResult;
  logic [WIDTH-1:0] RD2;
  logic [WIDTH-1:0] Result;
  logic             RegWrite;
  logic             ResultSrc;
  logic             MemWrite;
  logic [      3:0] ALUControl;
  logic             ALUSrc;
  logic [      2:0] ImmSrc;
  logic             PCSrc;
  logic             Jump;
  logic             JumpReg;
  logic [      2:0] Type;
  logic             PCUppSrc;
  logic             ImmUppSrc;
  logic             Zero;

  // PC Module
  PCtop PCT (
      .CLK(CLK),
      .rst(rst),
      .PCSrc(PCSrc),
      .JumpReg(JumpReg),
      .Result(Result),
      .ImmExt(ImmExt),
      .PC(PC)
  );

  // Instr Memory Module
  InstrMemory IM (
      .A (PC[27:0]),
      .RD(Instr)
  );

  // Control Unit Module
  ControlUnit CU (
      .op(Instr[6:0]),
      .funct3(Instr[14:12]),
      .funct7(Instr[30]),
      .Zero(Zero),
      .Jump(Jump),
      .JumpReg(JumpReg),
      .PCSrc(PCSrc),
      .ResultSrc(ResultSrc),
      .Type(Type),
      .MemWrite(MemWrite),
      .ALUControl(ALUControl),
      .ALUSrc(ALUSrc),
      .ImmSrc(ImmSrc),
      .RegWrite(RegWrite),
      .PCUppSrc(PCUppSrc),
      .ImmUppSrc(ImmUppSrc)
  );

  // Sign Extend Unit
  SignExtend SE (
      .Imm(Instr[31:7]),
      .ImmSrc(ImmSrc),
      .ImmExt(ImmExt)
  );

  // ALU Module
  ALUtop ALUT (
      .CLK(CLK),
      .trigger(trigger),
      .Jump(Jump),
      .ALUSrc(ALUSrc),
      .ALUControl(ALUControl),
      .RegWrite(RegWrite),
      .PCUppSrc(PCUppSrc),
      .ImmUppSrc(ImmUppSrc),
      .A1(Instr[19:15]),
      .A2(Instr[24:20]),
      .A3(Instr[11:7]),
      .PC(PC),
      .ImmExt(ImmExt),
      .Result(Result),
      .Zero(Zero),
      .ALUResult(ALUResult),
      .RD2(RD2),
      .a0(a0)
  );

  // Memory Module
  Memorytop MT (
      .CLK(CLK),
      .ALUResult(ALUResult),
      .RD2(RD2),
      .Type(Type),
      .MemWrite(MemWrite),
      .ResultSrc(ResultSrc),
      .Result(Result)
  );

  // Dsiplay
  always_comb begin
    // $display("Instruction: %h", Instr);
    // $display("ALUControl: %b", ALUControl);
    // $display("ALUResult: %h", ALUResult);
    // $display("a0: %b", a0);
  end
endmodule

module cpu #(
    parameter WIDTH = 32
) (
    input logic CLK,
    input logic rst,
    output logic [WIDTH-1:0] a0
);

  wire [WIDTH-1:0] PC;
  wire [WIDTH-1:0] Instr;
  wire [WIDTH-1:0] ImmExt;
  wire             RegWrite;
  wire             ResultSrc;
  wire             MemWrite;
  wire [      2:0] ALUControl;
  wire             ALUSrc;
  wire [      2:0] ImmSrc;
  wire             PCSrc;
  wire             Zero;

  // PC Module
  PCtop PCT (
      .CLK(CLK),
      .rst(rst),
      .PCSrc(PCSrc),
      .ImmExt(ImmExt),
      .PC(PC)
  );

  // Instr Mem Module
  InstrMem IM (
      .A (PC[19:0]),
      .RD(Instr)
  );

  // Control Unit Module
  ControlUnit CU (
      .op(Instr[6:0]),
      .funct3(Instr[14:12]),
      .funct7(Instr[31:25]),
      .Zero(Zero),
      .PCSrc(PCSrc),
      .ResultSrc(ResultSrc),
      .MemWrite(MemWrite),
      .ALUControl(ALUControl),
      .ALUSrc(ALUSrc),
      .ImmSrc(ImmSrc),
      .RegWrite(RegWrite)
  );

  // Sign Extend Unit
  SignExtend SE (
      .Instr (Instr[31:7]),
      .ImmSrc(ImmSrc),
      .ImmExt(ImmExt)
  );

  // ALU Module
  ALUtop ALU (
      .CLK(CLK),
      .ALUSrc(ALUSrc),
      .ALUControl(ALUControl),
      .RegWrite(RegWrite),
      .A1(Instr[19:15]),
      .A2(Instr[24:20]),
      .A3(Instr[11:7]),
      .ImmExt(ImmExt),
      .ResultSrc(ResultSrc),
      .MemWrite(MemWrite),
      .Zero(Zero),
      .a0(a0)
  );

  always_comb begin
    $display("a0: ", a0);
    $display("RegWrite: ", RegWrite);
    $display("Write Address:", Instr[11:7]);
    $display("ResultSrc: ", ResultSrc);

  end

endmodule

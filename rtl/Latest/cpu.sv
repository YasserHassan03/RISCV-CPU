module cpu (
    input logic CLK,
    input logic trigger,
    input logic rst,
    output logic [31:0] a0
);

  // Fetch Inputs
//logic [31:0] PCTargetE;
//logic        JumpRegW;
//logic [31:0] ResultW;
  logic        PCSrcE;

  // Fetch outputs
  logic [31:0] InstrF;
  logic [31:0] PCF;
  logic [31:0] PCPlus4F;


  // PC Module
  PCtop PCT (
      .CLK(CLK),
      .rst(rst),
      .PCSrc(PCSrcE),
      .JumpReg(JumpRegE),
      .Result(ALUResultE),
      .PCTarget(PCTargetE),
      .PCPlus4(PCPlus4F),
      .PC(PCF)
  );

  // Instr Memory Module
  InstrMemory IM (
      .A (PCF),
      .RD(InstrF)
  );

  // Decode Inputs
  logic [31:0] InstrD;
  logic [31:0] PCD;
  logic [31:0] PCPlus4D;
//logic        RegWriteW;
//logic [11:7] RdW;
  logic [31:0] ResultW;

  // PIPELINE FETCH-DECODE FF
  FetchDecff FD (
      .CLK(CLK),
      .InstrF(InstrF),
      .PCF(PCF),
      .PCPlus4F(PCPlus4F),
      .InstrD(InstrD),
      .PCD(PCD),
      .PCPlus4D(PCPlus4D)
  );

  // Decode Outputs
  logic        RegWriteD;
  logic [1:0]  ResultSrcD;
  logic        MemWriteD;
  logic        JumpD;
  logic        JumpRegD;
  logic [2:0]  TypeD;
  logic        BranchD;
  logic [3:0]  ALUControlD;
  logic        ALUSrcD;  
  logic [31:0] RD1D;
  logic [31:0] RD2D;
  logic [31:0] ImmExtD;   
  
  // Decode Internal
  logic [2:0]  ImmSrcD;
  logic [31:0] RD1Din;
  logic        RD1SrcD;

  // Register File Module
  RegisterFile RF (
      .CLK(CLK),
      .trigger(trigger),
      .WE3(RegWriteW),
      .A1 (InstrD[19:15]),
      .A2 (InstrD[24:20]),
      .A3 (RdW),
      .WD3(ResultW),
      .RD1(RD1Din),
      .RD2(RD2D),
      .a0 (a0)
  );

  // RD1D MUX 
  assign RD1D = RD1SrcD ? PCD : RD1Din; 

  // Control Unit Module
  ControlUnit CU (
      .op(InstrD[6:0]),
      .funct3(InstrD[14:12]),
      .funct7(InstrD[30]),
      .RegWrite(RegWriteD),
      .ResultSrc(ResultSrcD),
      .MemWrite(MemWriteD),
      .Jump(JumpD),
      .JumpReg(JumpRegD),
      .Type(TypeD),
      .Branch(BranchD),
      .ALUControl(ALUControlD),
      .ALUSrc(ALUSrcD),
      .ImmSrc(ImmSrcD),
      .RD1Src(RD1SrcD)
  );

  // Sign Extend Unit
  SignExtend SE (
      .Imm(InstrD[31:7]),
      .ImmSrc(ImmSrcD),
      .ImmExt(ImmExtD)
  );

  // Execute Inputs
  logic        RegWriteE;
  logic [1:0]  ResultSrcE;
  logic        MemWriteE;
  logic        JumpE;    
  logic        JumpRegE;
  logic [2:0]  TypeE; 
  logic        BranchE;   
  logic [3:0]  ALUControlE;
  logic        ALUSrcE;  
  logic [31:0] RD1E;     
  logic [31:0] RD2E;      
  logic [31:0] PCE;       
  logic [11:7] RdE;      
  logic [31:0] ImmExtE;   
  logic [31:0] PCPlus4E;
  logic        funct3LSBE;
  logic        funct3MSBE;  
    
  // PIPELINE DECODE-EXECUTE FF    
  DecExeff DE (
    .CLK(CLK),
    .RegWriteD(RegWriteD),
    .ResultSrcD(ResultSrcD),
    .MemWriteD(MemWriteD),
    .JumpD(JumpD),
    .JumpRegD(JumpRegD),
    .TypeD(TypeD),
    .BranchD(BranchD),
    .ALUControlD(ALUControlD),
    .ALUSrcD(ALUSrcD),
    .funct3LSBD(InstrD[12]),
    .funct3MSBD(InstrD[14]),
    .RD1(RD1D),
    .RD2(RD2D),
    .PCD(PCD),
    .RdD(InstrD[11:7]),
    .ImmExtD(ImmExtD),
    .PCPlus4D(PCPlus4D),
    .RegWriteE(RegWriteE),
    .ResultSrcE(ResultSrcE),
    .MemWriteE(MemWriteE),
    .JumpE(JumpE),
    .JumpRegE(JumpRegE),
    .TypeE(TypeE),
    .BranchE(BranchE),
    .ALUControlE(ALUControlE),
    .ALUSrcE(ALUSrcE),
    .funct3LSBE(funct3LSBE),
    .funct3MSBE(funct3MSBE),
    .RD1E(RD1E),
    .RD2E(RD2E),
    .PCE(PCE),
    .RdE(RdE),
    .ImmExtE(ImmExtE),
    .PCPlus4E(PCPlus4E)
  ); 
       
  // Execute Outputs
  logic [31:0] ALUResultE;
  logic [31:0] PCTargetE;

  // Execute Internal
  logic [31:0] SrcBE;
  logic        ZeroE;

  // SrcB MUX
  assign SrcBE = ALUSrcE ? ImmExtE : RD2E;

  // ALU Module
  ALU ALU (
      .ALUControl(ALUControlE),
      .SrcA(RD1E),
      .SrcB(SrcBE),
      .ALUResult(ALUResultE),
      .Zero(ZeroE)
  );

  // PCSrc Logic
  assign PCSrcE = (BranchE & (funct3MSBE ^ (funct3LSBE ^ ZeroE))) || JumpE;

  // PCTarget Logic
  assign PCTargetE = ImmExtE + PCE;

  // Memory Inputs
  logic        RegWriteM;
  logic [1:0]  ResultSrcM;
  logic        MemWriteM;
  logic [2:0]  TypeM;
  logic [31:0] ALUResultM;
  logic [31:0] WriteDataM;
  logic [11:7] RdM;
  logic [31:0] ImmExtM;
  logic [31:0] PCPlus4M;

  // PIPELINE EXECUTE-MEMORY FF
  ExeMemff EM(
      .CLK(CLK),
      .RegWriteE(RegWriteE),
      .ResultSrcE(ResultSrcE),
      .MemWriteE(MemWriteE),
      .TypeE(TypeE),
      .ALUResultE(ALUResultE),
      .WriteDataE(RD2E),
      .RdE(RdE),
      .ImmExtE(ImmExtE),
      .PCPlus4E(PCPlus4E),
      .RegWriteM(RegWriteM),
      .ResultSrcM(ResultSrcM),
      .MemWriteM(MemWriteM),
      .TypeM(TypeM),
      .ALUResultM(ALUResultM),
      .WriteDataM(WriteDataM),
      .RdM(RdM),
      .ImmExtM(ImmExtM),
      .PCPlus4M(PCPlus4M)
  );

  // Memory Outputs
  logic [31:0] ReadDataM;

  // Memory Module
  Memorytop MT (
      .CLK(CLK),
      .ALUResult(ALUResultM),
      .WDIn(WriteDataM),
      .Type(TypeM),
      .MemWrite(MemWriteM),
      .Data(ReadDataM)
  );

  // Write Inputs
  logic        RegWriteW;
  logic [1:0]  ResultSrcW;
  logic [31:0] ALUResultW;
  logic [31:0] ReadDataW;
  logic [11:7] RdW;
  logic [31:0] ImmExtW;
  logic [31:0] PCPlus4W;

  // PIPELINE MEMORY-WRITE FF
  MemWriteff MW (
    .CLK(CLK),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .ALUResultM(ALUResultM),
    .RdM(RdM),
    .ImmExtM(ImmExtM),
    .PCPlus4M(PCPlus4M),
    .ReadDataM(ReadDataM),
    .RegWriteW(RegWriteW),
    .ResultSrcW(ResultSrcW),
    .ALUResultW(ALUResultW),
    .RdW(RdW),
    .ImmExtW(ImmExtW),
    .PCPlus4W(PCPlus4W),
    .ReadDataW(ReadDataW)
  );

  // Result MUX
  always_comb begin
    case (ResultSrcW)
        2'b00:  ResultW = ALUResultW;
        2'b01:  ResultW = ReadDataW;
        2'b10:  ResultW = PCPlus4W;
        2'b11:  ResultW = ImmExtW;
    endcase
  end

endmodule

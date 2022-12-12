module Memorytop (
    input               CLK,
    input  logic [31:0] ALUResult,
    input  logic [31:0] RD2,
    input  logic [ 2:0] Type,
    input  logic        MemWrite,
    input  logic        ResultSrc,
    output logic [31:0] Result
);

  logic [31:0] ReadData;
  logic [31:0] WriteData;
  logic [31:0] Data;

  // Store Memory Module
  StoreMemory SM (
      .A(ALUResult[1:0]),
      .Type(Type[1:0]),
      .RDIn(ReadData),
      .WDIn(RD2),
      .WDOut(WriteData)
  );

  // Data Memory Module
  DataMemory DM (
      .A  ({{ALUResult[27:2]}, {2'b00}}),
      .WD (WriteData),
      .WE (MemWrite),
      .RD (ReadData),
      .CLK(CLK)
  );

  // Load Memory Module
  LoadMemory LM (
      .A(ALUResult[1:0]),
      .Type(Type),
      .RDIn(ReadData),
      .RDOut(Data)
  );

  // Output MUX
  assign Result = ResultSrc ? Data : ALUResult;


endmodule

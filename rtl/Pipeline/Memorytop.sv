module Memorytop (
    input               CLK,
    input  logic [31:0] ALUResult,
    input  logic [31:0] WDIn,
    input  logic [ 2:0] Type,
    input  logic        MemWrite,
    output logic [31:0] Data
);

  logic [31:0] ReadData;
  logic [31:0] WriteData;

  // Store Memory Module
  StoreMemory SM (
      .A(ALUResult[1:0]),
      .Type(Type[1:0]),
      .RDIn(ReadData),
      .WDIn(WDIn),
      .WDOut(WriteData)
  );

  // Data Memory Module
  DataMemory DM (
      .A  ({{ALUResult[31:2]}, {2'b00}}),
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

endmodule

module ExeMemff #(
    parameter WIDTH = 32
) (
    input  logic RegWriteE,
    input  logic [1:0] ResultSrcE,
    input  logic MemWriteE,
    input  logic JumpE,
    input  logic JumpRegE,
    input  logic [WIDTH-1:0] AluResultE,
    input  logic [WIDTH-1:0] WriteDataE, //RD2E
    input  logic [11:7]RdE,
    input  logic [WIDTH-1:0] ImmExtE,
    input  logic [WIDTH-1:0] PCPlus4E,
    input  logic CLK,
    output logic  RegWriteM,
    output logic  [1:0] ResultSrcM,
    output logic  MemWriteM,
    output logic  JumpM,
    output logic  JumpRegM,
    output logic  [WIDTH-1:0] AluResultM,
    output logic  [WIDTH-1:0] WriteDataM, 
    output logic  [11:7] RdM,
    output logic  [WIDTH-1:0] ImmExtM,
    output logic  [WIDTH-1:0] PCPlus4M   
);
always_ff @(posedge CLK) begin
    RegWriteM <= RegWriteE;
    ResultSrcM <= RegWriteE;
    MemWriteM <= MemWriteE;
    JumpM <= JumpE;
    JumpRegM <= JumpRegE;
    AluResultM <= AluResultE;
    WriteDataM <= WriteDataE;
    RdM <= RdE;
    ImmExtM <= ImmExtE
    PCPlus4M <= PCPlus4E
end

endmodule

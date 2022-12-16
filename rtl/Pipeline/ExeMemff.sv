module ExeMemff #(
    parameter WIDTH = 32
) (
    input  logic             CLK,
    input  logic             RegWriteE,
    input  logic [1:0]       ResultSrcE,
    input  logic             MemWriteE,
    input  logic [2:0]       TypeE,
    input  logic [WIDTH-1:0] ALUResultE,
    input  logic [WIDTH-1:0] WriteDataE,
    input  logic [11:7]      RdE,
    input  logic [WIDTH-1:0] ImmExtE,
    input  logic [WIDTH-1:0] PCPlus4E,
    output logic             RegWriteM,
    output logic [1:0]       ResultSrcM,
    output logic             MemWriteM,
    output logic [2:0]       TypeM,
    output logic [WIDTH-1:0] ALUResultM,
    output logic [WIDTH-1:0] WriteDataM, 
    output logic [11:7]      RdM,
    output logic [WIDTH-1:0] ImmExtM,
    output logic [WIDTH-1:0] PCPlus4M   
);

always_ff @(posedge CLK) begin
    RegWriteM <= RegWriteE;
    ResultSrcM <= ResultSrcE;
    MemWriteM <= MemWriteE;
    TypeM <= TypeE;
    ALUResultM <= ALUResultE;
    WriteDataM <= WriteDataE;
    RdM <= RdE;
    ImmExtM <= ImmExtE;
    PCPlus4M <= PCPlus4E;
end

endmodule

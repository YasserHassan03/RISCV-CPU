module MemWriteff #(
    parameter WIDTH = 32
)(
    input  logic             CLK,
    input  logic             RegWriteM,
    input  logic [1:0]       ResultSrcM,
    input  logic [WIDTH-1:0] ALUResultM,
    input  logic [11:7]      RdM,
    input  logic [WIDTH-1:0] ImmExtM,
    input  logic [WIDTH-1:0] PCPlus4M,
    input  logic [WIDTH-1:0] ReadDataM,
    output logic             RegWriteW,
    output logic [1:0]       ResultSrcW,
    output logic [WIDTH-1:0] ALUResultW,
    output logic [11:7]      RdW,    
    output logic [WIDTH-1:0] ImmExtW,
    output logic [WIDTH-1:0] PCPlus4W,
    output logic [WIDTH-1:0] ReadDataW
);

    always_ff @(posedge CLK) begin
        RegWriteW <= RegWriteM;
        ResultSrcW <=ResultSrcM;
        ALUResultW <= ALUResultM;
        RdW <= RdM;
        ImmExtW <= ImmExtM;
        PCPlus4W <= PCPlus4M;
        ReadDataW <= ReadDataM;
    end

endmodule

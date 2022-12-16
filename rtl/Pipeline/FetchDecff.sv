module FetchDecff #(
    parameter WIDTH = 32
)(
    input  logic             CLK,
    input  logic [WIDTH-1:0] InstrF,
    input  logic [WIDTH-1:0] PCF,
    input  logic [WIDTH-1:0] PCPlus4F,
    output logic [WIDTH-1:0] InstrD,
    output logic [WIDTH-1:0] PCD,
    output logic [WIDTH-1:0] PCPlus4D
);

always_ff @(posedge CLK) begin
    InstrD   <= InstrF;
    PCD      <= PCF;
    PCPlus4D <= PCPlus4F;
end

endmodule

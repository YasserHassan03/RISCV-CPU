module DataMemory #(
    parameter A_WIDTH = 28,
    RD_WIDTH = 32,
    WD_WIDTH = 32,
    D_WIDTH = 8
) (
    input  logic                CLK,
    input  logic [WD_WIDTH-1:0] WD,
    input  logic [ A_WIDTH-1:0] A,
    input  logic                WE,
    output logic [RD_WIDTH-1:0] RD
);
  // RAM Array
  logic [D_WIDTH-1:0] RAM[2**A_WIDTH-1:0];

  // Load RAM from mem file
  initial begin
    $display("Loading RAM");
    $readmemh("./test/Memory/gaussian.mem", RAM, 32'h10000);
    $display("Data written to RAM successfully");
  end

  // Assign Output
  assign RD = {RAM[A+3], RAM[A+2], RAM[A+1], RAM[A]};

  // Write to RAM lil endian
  always_ff @(posedge CLK) begin
    if (WE == 1'b1) begin
      RAM[A+3] <= WD[31:24];
      RAM[A+2] <= WD[23:16];
      RAM[A+1] <= WD[15:8];
      RAM[A]   <= WD[7:0];
    end
  end
endmodule
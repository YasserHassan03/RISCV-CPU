module PCReg #(
    parameter D_WIDTH = 32
) (
    input  logic               CLK,
    input  logic               rst,
    input  logic [D_WIDTH-1:0] PCNext,
    output logic [D_WIDTH-1:0] PC
);

  // Clocked Register with Reset
  always_ff @(posedge CLK)
    if (rst) PC <= 32'b0;
    else PC <= PCNext;

  // Displays PC on terminal
  always_comb begin
    $display("\n\n\n");
    $display("Program Counter: ", PC);
  end

endmodule

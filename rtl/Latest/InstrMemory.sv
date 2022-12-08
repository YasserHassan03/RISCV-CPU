module InstrMemory #(
    parameter A_WIDTH = 28,
    D_WIDTH = 8
) (
    input  logic [  A_WIDTH-1:0] A,
    output logic [4*D_WIDTH-1:0] RD
);

  // ROM Array
  logic [D_WIDTH-1:0] ROM[2**A_WIDTH-1:0];

  // Load ROM from mem file
  initial begin
    $display("Loading ROM");
    $readmemh("InstrMemory.mem", ROM);
    $display("Instructions written to ROM successfully");
  end

  // Assign Output
  assign RD = {{ROM[A+3]}, {ROM[A+2]}, {ROM[A+1]}, {ROM[A]}};

endmodule

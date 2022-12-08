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
    $readmemh("DataMemory.mem", RAM);
    $display("Instructions written to RAM successfully");
    // for (int i=0; i<$size(DataMemory);i++)
    //     $display(DataMemory[i]," ");
    //     DataMemory[i]=32'b0;
  end

  // Assign Output
  assign RD = {RAM[A], RAM[A+1], RAM[A+2], RAM[A+3]};

  // Write to RAM
  always_ff @(posedge CLK) begin
    if (WE == 1'b1) begin
      RAM[A]   <= WD[31:24];
      RAM[A+1] <= WD[23:16];
      RAM[A+2] <= WD[15:8];
      RAM[A+3] <= WD[7:0];
    end
  end
endmodule

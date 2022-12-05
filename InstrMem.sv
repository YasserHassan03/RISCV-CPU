module InstrMem #(
    parameter   A_WIDTH = 20,
                D_WIDTH = 8
)(
    input  logic [A_WIDTH-1:0]   A,
    output logic [4*D_WIDTH-1:0] RD 
);

    logic [D_WIDTH-1:0] ROM [2**A_WIDTH-1:0];

    initial begin 
        $display ("Loading ROM");
        $readmemh("InstrMem.mem",ROM);
        $display ("Instructions written to ROM successfully");
    end

    assign RD = {{ROM[A]}, {ROM[A+1]}, {ROM[A+2]}, {ROM[A+3]}};

endmodule

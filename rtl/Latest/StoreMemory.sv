module StoreMemory (
    input  logic [ 1:0] A,
    input  logic [ 1:0] Type,
    input  logic [31:0] RDIn,
    input  logic [31:0] WDIn,
    output logic [31:0] WDOut
);

  always_comb begin
    case (Type)
      // Byte
      2'b00:
      case (A) 
        2'b00: WDOut = {{RDIn[31:8]}, {WDIn[7:0]}};
        2'b01: WDOut = {{{RDIn[31:16]}, {WDIn[7:0]}}, {RDIn[7:0]}};
        2'b10: WDOut = {{{RDIn[31:24]}, {WDIn[7:0]}}, {RDIn[15:0]}};
        2'b11: WDOut = {{WDIn[7:0]}, {RDIn[23:0]}};
      endcase
      // Half
      2'b01: WDOut = A[1] ? {{WDIn[31:16]}, RDIn[15:0]} : {{RDIn[31:16]}, {WDIn[15:0]}};
      // Word
      2'b10: WDOut = WDIn;
      // Default
      default: WDOut = WDIn;
    endcase
  end


endmodule

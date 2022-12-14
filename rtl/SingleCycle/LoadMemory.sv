module LoadMemory (
    input  logic [ 1:0] A,
    input  logic [ 2:0] Type,
    input  logic [31:0] RDIn,
    output logic [31:0] RDOut
);

  always_comb begin
    case (Type)
      // Signed Byte
      3'b000:
      case (A)
        2'b00: RDOut = {{24{RDIn[7]}}, {RDIn[7:0]}};
        2'b01: RDOut = {{24{RDIn[15]}}, {RDIn[15:8]}};
        2'b10: RDOut = {{24{RDIn[23]}}, {RDIn[23:16]}};
        2'b11: RDOut = {{24{RDIn[31]}}, {RDIn[31:24]}};
      endcase
      // Signed Half
      3'b001: RDOut = A[1] ? {{RDIn[31:16]}, {16{1'b0}}} : {{16{RDIn[15]}}, {RDIn[15:0]}};
      // Word
      3'b010: RDOut = RDIn;
      // Unsigned Byte
      3'b100:
      case (A)
        2'b00: RDOut = {{24{1'b0}}, {RDIn[7:0]}};
        2'b01: RDOut = {{24{1'b0}}, {RDIn[15:8]}};
        2'b10: RDOut = {{24{1'b0}}, {RDIn[23:16]}};
        2'b11: RDOut = {{24{1'b0}}, {RDIn[31:24]}};
      endcase
      // Unsigned Half
      3'b101: RDOut = A[1] ? {{RDIn[31:16]}, {16{1'b0}}} : {{16{1'b0}}, {RDIn[15:0]}};
      // Default
      default: RDOut = RDIn;
    endcase
  end


endmodule

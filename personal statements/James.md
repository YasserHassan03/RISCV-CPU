# Introduction
The sections which I was responsible for was the program counter and the RAM modules.

However, due to the highly interconnected nature of the project with the need for inputs and outputs in my module being from other sections like (ALU, Control etc),
I often collaborated with other members of the team to ensure that the naming of wires etc was standard and that the modules would interct with each other in the required way.

# Program Counter

Overall the program counter was fairly simple to make using the diagram from the lectures and the only difference between the program counter from LAB 4 was an additional 
multiplexer for the JALR instruction. 

The original program counter was capable of performing branch and plain jump (JAL) instructions as these require the next program counter value to be equal to the PC + 4. (It is +4 due to RISCV architecture having byte addressable memory and 32 bit word instruction consists of 4 bytes)

![alt text](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/blob/main/personal%20statements/images/pcold.png)

In order to implement the additional indirect jump instruction (Jump and Link register or JALR) we need to be able to obtain the next PC value by adding the 12-bit signed I-immediate to the register rs1. We did this by adding an extra multiplexer with an input from the result of the ALU (this carries the value of the imm12 + rs1).
I implemented this using the system verilog below.

```verilog
always_comb begin
    PCPlus4  = PC + 4;
    PCTarget = PC + ImmExt;
    PCInterm = PCSrc ? PCTarget : PCPlus4;
    PCNext   = JumpReg ? Result : PCInterm;
  end
  ```
*here the first mux is the original with the value PCinterm being fed into the additional mux which takes the result from the ALU as a second input*

The additional mux is controlled by a select called JumpReg which comes from the control logic and determines if a JALR is required. 

Deciding on this design choice required collaboration with the control unit and ALU.

Inside the Program counter there is also a register which is used to make the program memory asynchronous. We can preload this instruction memory with hex from a file.
This was already implemented from lab4 however required some minor adjustments in order to fit with the recommended memory map. The first address is 0xBFC00000 for the instruction memory.
```verilog
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
    if (rst) PC <= 32'hbfc00000;
    else PC <= PCNext;

endmodule
```
![alt text](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/blob/main/personal%20statements/images/memory%20map.png)






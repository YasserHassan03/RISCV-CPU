# Introduction
The sections which I was responsible for was the program counter and the RAM load/store modules.

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

## PC Register 

Inside the Program counter there is also a register which is used to make the program memory asynchronous.
This was already implemented from lab4 however required some minor adjustments in order to fit with the recommended memory map. The first address is set to 0xBFC00000 for the instruction memory.
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

## Instruction memory

# Memory Read/Write blocks

Because the memory in a RISC-V processor is byte-addressable we need some additional logic to be able to load/store bytes or halfwords or words for instructions such as lb/sb , lh/sh, lw/sw and lbu/lhu (more on these later).
In order to perform the above operations we need to output or input a 32 bit data values which is formed from the relevant bits extracted from the memory. Another key distinction for these blocks is that RISC-V memory is little endian. 

## Load https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/blob/main/rtl/Latest/LoadMemory.sv

![alt text](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/blob/main/personal%20statements/images/datamem.png)
*Using slide 12 from lecture 6 for below examples*

so for example if we wanted to load the 4th byte (MSB) of the word we would use an instruction like lb s3, 0x3
this would result in register s3 holding the value 0xFFFFFFAB (because lb is a signed operation and the MSB of AB is 0b1 it is assumed to be negative thus we extend keeping this sign)
``` verilog
case (Type)
      // Signed Byte
      3'b000:
      case (A)
        2'b00: RDOut = {{24{RDIn[7]}}, {RDIn[7:0]}};
        2'b01: RDOut = {{24{RDIn[15]}}, {RDIn[15:8]}};
        2'b10: RDOut = {{24{RDIn[23]}}, {RDIn[23:16]}};
        2'b11: RDOut = {{24{RDIn[31]}}, {RDIn[31:24]}};
      endcase
      
```
*note the variable **Type** is from an input from control and determines the type of addressing required for the instruction executed*

on the other hand if we wanted to do an unsigned operation we would use lbu s3, 0x3 which would result in register s3 holding 0x000000AB (where we do an unsigned extension)
``` verilog
// Unsigned Byte
      3'b100:
      case (A)
        2'b00: RDOut = {{24{1'b0}}, {RDIn[7:0]}};
        2'b01: RDOut = {{24{1'b0}}, {RDIn[15:8]}};
        2'b10: RDOut = {{24{1'b0}}, {RDIn[23:16]}};
        2'b11: RDOut = {{24{1'b0}}, {RDIn[31:24]}};
      endcase
```
Half word addressing would work in a similar way however would have addresses which increment in steps of 2. (eg lh s3, 0x2 would result in s3 holding 0xFFFFEF78 or 
lhu s3, 0x2 would result in s3 holding 0x0000EF78)
```verilog
// Unsigned Half
      3'b101: RDOut = A[1] ? {{RDIn[31:16]}, {16{1'b0}}} : {{16{1'b0}}, {RDIn[15:0]}};
// Signed Half
      3'b001: RDOut = A[1] ? {{16{RDIn[31]}}, {RDIn[31:16]}}:{{16{RDIn[15]}}, {RDIn[15:0]}};
   
   ```           
*The variable **A** contains the last two bits of the address so can be used to determine which byte in the word we want (so for for half-words we used a mux based on the MSB of A to check which multiple of 2 it is eg if A is 1 we would select the top 16 bits of the 32 bit word)*

ALso the design choice to use a ternary operator (mux) as opposed to another case statement is just to reduce lines *although on reflection it may be clearer to read if multiplexers are used to keep consistency with the rest of the module*

## Store https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/blob/main/rtl/Latest/StoreMemory.sv

The store memory block is very similar to the above load memory block however there is no need for a unsigned operation because the data is not being extracted from memory rather written to so we only want to overwrite the bytes/half-words we want to change (we don't need to extend the data to 32 bits rather only select the relevant bytes)
For example say s3 holds the value 0x12345678 "sh s3, 0x8" would put the value 0x56782842 into word 2 (overwriting the top half-word with the 16 LSBs of the data in we don't have an instruction to choose the 16 MSBs because this could be achieved by performing a shift operation and this is "**Reduced Instruction Set** Computing")
```verilog
// Half
      2'b01: WDOut = A[1] ? {{WDIn[15:0]}, RDIn[15:0]} : {{RDIn[31:16]}, {WDIn[15:0]}};
```
*this works in a very similar way to the read block with A denoting which multiple of 2 address we want*

Similarly for byte addressing "sb s3, 0x7" would put the value 0x01782842 into word 2 (overwriting the second-most significant byte or address 0x7)
``` verilog
case (Type)
      // Byte
      2'b00:
      case (A) 
        2'b00: WDOut = {{RDIn[31:8]}, {WDIn[7:0]}};
        2'b01: WDOut = {{{RDIn[31:16]}, {WDIn[7:0]}}, {RDIn[7:0]}};
        2'b10: WDOut = {{{RDIn[31:24]}, {WDIn[7:0]}}, {RDIn[15:0]}};
        2'b11: WDOut = {{WDIn[7:0]}, {RDIn[23:0]}};
      endcase
```
*using cases for which byte in the word we want to change*

All of the above operations are performed by concatenating the existing word in the RAM with the desired byte/half-word that we want to write. Of course the word addressed data is read as normal (using multiples of 4 addresses).












# Introduction
The sections which I were responsible for were the program counter, the RAM load/store modules and some pipelining.

However, due to the highly interconnected nature of the project with the need for inputs and outputs in my module being from other sections like (ALU, Control etc), I often collaborated with other [members of the team](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/graphs/contributors) to ensure that the naming of wires etc was standard and that the modules would interact with each other in the required way.

# [Program Counter](b32b3fddf4aad91a5fe431548dc000da9c4b4f72)

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

The additional mux is controlled by a select called JumpReg which comes from the control logic and determines if a JALR is required (JALR would need Result to be assigned to PCNext, Jumps and Branches need PCTarget to be assigned as next PC, normal isntructions would need PCPlus4). 

Deciding on this design choice required collaboration with the control unit and ALU teams.

## PC Register 

Inside the Program counter there is also a register which is used to store the next program counter value.
This was already implemented from Lab 4 however required some minor adjustments in order to fit with the recommended memory map. The first address is set to 0xBFC00000 for the instruction memory.
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

The instruction memory is loaded with hex instructions. It is also byte addressed (which explains why PC generally counts up in 4s to address the next 32 bit instruction word). Again this only required minor changes from lab4 to suit the memory map. We implemented this memory as a ROM with 4096 byte adresses (or 1024 32bit word addresses)

```Verilog
module InstrMemory #(
    parameter A_WIDTH = 32,
    D_WIDTH = 8
) (
    input  logic [  A_WIDTH-1:0] A,
    output logic [4*D_WIDTH-1:0] RD
);

  // ROM Array
  logic [D_WIDTH-1:0] ROM[32'hbfc00fff:32'hbfc00000];

  // Load ROM from mem file
  initial begin
    $display("Loading ROM");
    $readmemh("./test/Memory/pdfPipelined.mem", ROM);
    $display("Instructions written to ROM successfully");
  end

  // Assign Output
  assign RD = {{ROM[A+3]}, {ROM[A+2]}, {ROM[A+1]}, {ROM[A]}};

endmodule
```
*the above code loads our pipelined version of the sample pdf assembly*

Note: We concatenate with the largest byte address within the multiple of 4 being the most significant and the lowest being the least because RISC-V is little-endian.

# [Memory Read/Write blocks](5f27759820d96d0592d9490b78e0ef718877016f)

Because the memory in a RISC-V processor is byte-addressable we need some additional logic to be able to load/store bytes or halfwords or words for instructions such as lb/sb , lh/sh, lw/sw and lbu/lhu (more on these later).
In order to perform the above operations we need to output or input a 32 bit data values which is formed from the relevant bits extracted from the memory. Another key distinction for these blocks is that RISC-V memory is [little endian](3dab1128857fcf610456673179bf41b453f7ae6b). 
Note: After collaboration with the control logic we decided that a 3 bit control signal *Type* would be used to determine the type of addressing mode. The table below documents the control code standards we used.

| `Type[3:0]`| Addressing mode    |
|-----------|--------------------|
| 000       | signed byte        |
| 001       | signed half-word   |
| 010       | word               |
| 011       | N/A                |
| 100       | unsigned byte      |
| 101       | unsigned half-word |
| 111       | N/A                |


## [Load](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/blob/main/rtl/Latest/LoadMemory.sv)

![alt text](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/blob/main/personal%20statements/images/datamem.png)
*Using slide 12 from lecture 6 for below examples*

so for example if we wanted to load the 4th byte (MSB) of the word we would use an instruction like `lb s3, 0x3`
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

on the other hand if we wanted to do an unsigned operation we would use `lbu s3, 0x3` which would result in register `s3` holding `0x000000AB` (where we do an unsigned extension)
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
Half word addressing would work in a similar way however would have addresses which increment in steps of 2. (eg `lh s3, 0x2` would result in s3 holding `0xFFFFEF78` or 
`lhu s3, 0x2` would result in `s3` holding `0x0000EF78`)
```verilog
// Unsigned Half
      3'b101: RDOut = A[1] ? {{RDIn[31:16]}, {16{1'b0}}} : {{16{1'b0}}, {RDIn[15:0]}};
// Signed Half
      3'b001: RDOut = A[1] ? {{16{RDIn[31]}}, {RDIn[31:16]}}:{{16{RDIn[15]}}, {RDIn[15:0]}};
   
   ```           
*The variable **A** contains the last two bits of the address so can be used to determine which byte in the word we want (so for for half-words we used a mux based on the MSB of A to check which multiple of 2 it is eg if A is 1 we would select the top 16 bits of the 32 bit word)*

Also the design choice to use a ternary operator (mux) as opposed to another case statement is just to reduce lines *although on reflection it may be clearer to read if multiplexers are used to keep consistency with the rest of the module*

## [Store](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/blob/main/rtl/Latest/StoreMemory.sv)

[*Using example from slide 12 lecture 6 again*](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/blob/main/personal%20statements/images/datamem.png)

The store memory block is very similar to the above load memory block however there is no need for a unsigned operation because the data is not being extracted from memory rather written to so we only want to overwrite the bytes/half-words we want to change (we don't need to extend the data to 32 bits rather only select the relevant bytes)
For example say `s3` holds the value `0x12345678` `sh s3, 0x8` would put the value `0x56782842` into word 2 (overwriting the top half-word with the 16 LSBs of the data in we don't have an instruction to choose the 16 MSBs because this could be achieved by performing a shift operation and this is "**Reduced Instruction Set** Computing")
```verilog
// Half
      2'b01: WDOut = A[1] ? {{WDIn[15:0]}, RDIn[15:0]} : {{RDIn[31:16]}, {WDIn[15:0]}};
```
*this works in a very similar way to the read block with A denoting which multiple of 2 address we want*

Similarly for byte addressing `sb s3, 0x7` would put the value `0x01782842` into word 2 (overwriting the second-most significant byte or address 0x7)
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

# [Pipelining](90e321e6e3a837e361f548b3f2ff3378f6236c6c)
In order to implement pipelining we needed to insert registers between each of the five Fetch, Decode, Execute, Memory and Writeback stages. I added the register between the Decode and Execute stages. I also made sure that the register file was changed to be written on the NEGEDGE of CLK so that DATA can be written in the first half (rising edge) of the clock cycle and be written back for any following instruction in the second half (falling edge) of the clock cycle. 
Other than this it was simply a matter of identifying signals which leave the Decode section and enter the Execute stage. 
```Verilog
module DecExeff #(
    parameter WIDTH = 32
)(
    input  logic              CLK,        
    input  logic              RegWriteD,
    input  logic [1:0]        ResultSrcD,
    input  logic              MemWriteD,
    input  logic              JumpD, 
    input  logic [2:0]        TypeD,         
    input  logic              BranchD,      
    input  logic [3:0]        ALUControlD,
    input  logic              ALUSrcD,       
    input  logic              JumpRegD,
    input  logic              funct3LSBD,       
    input  logic              funct3MSBD,       
    input  logic [WIDTH-1:0]  RD1,            
    input  logic [WIDTH-1:0]  RD2,                    
    input  logic [WIDTH-1:0]  PCD,         
    input  logic [11:7]       RdD,         
    input  logic [WIDTH-1:0]  ImmExtD,         
    input  logic [WIDTH-1:0]  PCPlus4D, 
    output logic              RegWriteE,         
    output logic [1:0]        ResultSrcE,
    output logic              MemWriteE,         
    output logic              JumpE,         
    output logic              JumpRegE,         
    output logic [2:0]        TypeE,         
    output logic              BranchE,         
    output logic [3:0]        ALUControlE,         
    output logic              ALUSrcE,
    output logic              funct3LSBE, 
    output logic             funct3MSBE,       
    output logic [WIDTH-1:0]  RD1E,         
    output logic [WIDTH-1:0]  RD2E,         
    output logic [WIDTH-1:0]  PCE,         
    output logic [11:7]       RdE,         
    output logic [WIDTH-1:0]  ImmExtE,         
    output logic [WIDTH-1:0]  PCPlus4E         
);

    always_ff@(posedge CLK) begin
        RegWriteE <= RegWriteD;
        ResultSrcE <= ResultSrcD;
        MemWriteE <= MemWriteD;
        JumpE <= JumpD;
        JumpRegE <= JumpRegD;
        TypeE <= TypeD;
        BranchE <= BranchD;
        ALUControlE <= ALUControlD;
        ALUSrcE <= ALUSrcD;
        funct3LSBE <= funct3LSBD;
        RD1E <= RD1;
        RD2E <= RD2;
        PCE <= PCD;
        RdE <= RdD;
        ImmExtE <= ImmExtD;
        PCPlus4E <= PCPlus4D;
        funct3MSBE <= funct3MSBD;
    end 

endmodule
```
There is not much interesting to say about the above other than our design choices. I called all signals on the execute side "E" and "D" on the decode side. We also included *Type (which is used to determine the memory addressing mode), JumpReg (which is used for a JALR instruction), funct3LSB and funct3MSB (which is used 
to calculate the PCSrc control signal used for branch, jump and jump and link instructions).*
We decided on these standards after discussing the implementation of these instructions as a team.
One other change for the pipelined version of the PC module was moving the PCTarget value out of the ALU module into the top module as this made it clearer for us to see where the signal comes from. 

```Verilog
// PCTarget Logic
  assign PCTargetE = ImmExtE + PCE;
  ```
*PCTargetE is assigned to the value of the ImmExtE plus PCE used for JAL and Branch instructions (we could have put this inside the PC using an input as before but we moved it [outside](0451370fa410d4f4874bc9eaaca7267bf25a280e) for clarity*

# F1 Program pipelining

Initially we had the idea of storing random values in the RAM and then using the time taken to press the trigger to choose a value for the F1 lights delay for the best "Randomness" however after discussing this in more detail we decided that this was not very practical and instead agreed on using the primitive polynomial method used in lab 3. 
[Ahmad](https://github.com/ahumayde) wrote the F1 lights assembly program and explains how it woks in more detail in his personal statement. I [adapted](850926068f04a58656f76d114301d1276a7c1742) the program and made it suitable for our pipelined CPU design by identifying data/control hazards and inserting *NOP* instructions to delay the operation until the data had been written to register file or control signal had reached the [relevant stage](ec3e00c44f53d1de0ac4a8dcc1d416debbf79514).

```Assembly
default:
    addi s1, zero, 0x1  
    addi s2, zero, 0xff 
    addi s3, zero, 0x3  /* MAY MAKE BIGGER */
    addi a3, zero, 0x1 

reset:
    addi a0, zero, 0x0  /* reset output */
    addi a4, zero, 0x0  /* reset delay counter */
    addi t0, zero, 0x0  /* reset trigger */
    nop
    nop

mloop:
    beq  t0, s1, fsm    /* check trigger */ 
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop
    srli a2, a3, 0x3    /* send 4th bit to 1st bit */
    nop                 /* one cycle delay to get result through memory section*/
    nop                 /* one cycle delay to write result on negative edge*/
    xor  a2, a2, a3     /* xor 4th bit and 1st bit */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    andi a2, a2, 0x1    /* remove other bits */
    slli a3, a3, 0x1    /* shift number left by 1 */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    add  a3, a3, a2     /* add xor and shifted bits */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    andi a3, a3, 0xf    /* remove additional bits */
    jal  ra, mloop      /* Loop  */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop

fsm:
    jal  ra, count      /* add const delay */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop
    slli t1, a0, 0x1    /* shift temp output bits left by 1 */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    addi a0, t1, 0x1    /* add 1 to shifted bits for output */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /*one cycle delay to write result on negative edge*/
    bne  a0, s2, fsm    /* if not all lights are on Loop */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop
delay:
    beq  a4, a3, reset  /* if delay counter is finished reset */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop
    jal  ra, count      /* jump to counter MAY NOT NEED THIS */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop
    addi a4, a4, 0x1    /* increment delay counter */
    jal  ra, delay      /* Loop */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop

count: 
    addi  a1, a1, 0x1   /* counter++ */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    bne   a1, s3, count /* Loop if counting */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    addi  a1, zero, 0x0 /* reset counter */
    jalr  ra, ra, 0x0   /* return to fsm */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop
```
*one thing we noticed was that often we needed two nop instructions due to the two registers between the fetch and execute stages of pipelined cpu*

# Reflection

Overall, I learned alot about System Verilog, Assembly code and RISC-V architecture during this project. One thing that I would do differently if we were to repeat would be to try and do more testing of my individual modules before putting all of the modules together and then testing as an overall team. I think this would have made it easier and faster to debug in the end. Also, if we had more time it would be nice to have a go at implementing cache or possibly using some sort of hardware (hazard unit) to implement delays without manually having to go through and add delays in software. 












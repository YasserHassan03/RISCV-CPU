# Introduction:


Following the lecture slides from lecture 7 we decided  split the Control Unit
I was mainly in charge of the Control Decoders. This required a great deal of communication between all other members. I often found myself as the middle man when communicating between the others and felt as though towards the end we were working fluidly as a team. Due to being the principle contributer of the decoders it was natural that I would have also work on debugging. -- CHANGE

# Main Decoder

### Initial ALU and Main Decoder top view 

<img height="400" alt="Screenshot 2022-12-12 at 12 35 52" src="https://user-images.githubusercontent.com/116260803/207046709-8aafcf19-7cbc-48a6-9f66-cbe0b43898f8.png">


As seen in the picture above (taken from lecture 7), the control unit takes in 4 inputs, the zero flag (used for branches) , opcode (determines which type of instruction we are doing), funct3 (tells us which ALU instruction), and funct7 bit 5 (this distinguishes between arithmetic/logical shifts and add/sub).

With our Lab 4 CPU, there were only a small selection of instructions that we had implemented at the time and so we required a small number and size of control signal outputs. For example, In the Main Decoder module ImmSrc would now require 3 bits for the 6 types of instructions we implemented for our completed single cycle CPU namely R, I, UI, S, B and J. 

In addition to ImmSrc requiring and additional bit, through  our combined effort we decided on 5 additional control signals which would be required from the Main Decoder Module in order to implement all additional instructions found in Lecture 6: 

* Jump
  * Used for JAL and JALR
  
* JumpReg
  * Used for JAL  
  
* PCUppSrc
  * Used for AUIPC

* ImmUppSrc
  * Used for LUI

* Type<sub>[2:0]</sub>
  * Used for all Store and Load instructions

As I previously added comments for the additional instruction op cases, the only step from here was to assign the correct values to the correct op cases for the given instructions. As simple as this sounds, due to slight carelessness, I still managed to mess it up in the beggining. Luckily with the help of ***the team*** and good communication between all members we were able to debug these errors swiftly.

### Example

```systemverilog
   // Branch - B   
      // Branch Instructions    
      7'd99: begin
        ImmSrc = 3'b011;
        ALUOp  = 2'b01;
        ALUSrc = 1'b0;
        Branch = 1'b1;
      end
```
The 7'd99 at the start here corresponds to a branch instruction and is taken from the risc-v instruction set.
Immsrc is set to '011' beacuse in our sign extend unit, we have chosen to set 011 corresponding to read Imm as branch instructions. 
The ALUop 2'b01 is because in ALU decoder we have chosen this to correspond to branches.
The ALUsrc is set to 0 so that in our ALU we can compare two register values. The ALUsrc acts as a select to a mux just before the ALU thus deciding what goes into the ALU.
Finally, since it is a branch instruction we set branch signal equal to 1 so that we can change PCSRC as talked about above.

# ALU Decoder

### ALU Decoder logic taken from Lecture 7
<img width="451" alt="Screenshot 2022-12-16 at 11 32 59" src="https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/blob/main/personal%20statements/images/Lecture7ALUDecode.png">

Originally, I used nested case statements in the ALU Decoder with ALUOp, op5, funct7<sub>5</sub> and funct3 as the selects and ALUControl as the output. This was because at the time of Lab 4 we simply followed lectures as close as was possible and case should automatically synthesize an optimal circuit. However, I did not like this implementation as it was ***"too brute force"***. Not only that, my teamate also requires the output ALUControl contain extra bits from funct7<sub>5</sub> to differentiate between add/sub and the arithmetic/logical shifts. 

In order to resolve this, we discussed what we could do in order to better encode the ALUControl and thus we had to reorder the case statement inside the ALU module. Furthermore, it occurred to us that our new signal ***Type<sub>[2:0]</sub>*** could solely be mapped to funct3 for load and store instructions. Thus, we ended up with a very nice method to implement ALUControl for all instructions that require it as a logic function of funct3, funct7<sub>5</sub> and single case statement for ALUOp. 

This can be seen in the code below and in [this commit](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/commit/9af154a38f7c214f65b6d99d54e3a47248f263a4):

```systemverilog
    // Load Store 
    2'b00: begin
      ALUControl = 4'b0000;
      Type = funct3;
    end
    // Branch (bne/beq = 0000, blt/bge = 0010, bltu/bgeu = 0011)
    2'b01:   ALUControl = funct3[2] ? {{3'b001}, {funct3[1]}} : 4'b0000;
    // ALU bit 3 only matters for add/sub vs rsl/rsa so we can us funct3[2] to determine it
    2'b10:   ALUControl = {{funct3[2] ? {funct7} : {funct7 & op5}}, {funct3}};
    // Default
    default: ALUControl = 4'b0000;
```

# Sign Extend Unit

Each Imm set-up is different for each type of instruction (I,UI,S,B,J) as seen below (from lecture 6):

<img width="1339" alt="Screenshot 2022-12-12 at 14 07 51" src="https://user-images.githubusercontent.com/116260803/207066709-afed76d9-bc9a-47de-9cc5-10c0e58c0d20.png">

Note: for jumps and branch, our immediate starts from 1 not 0 because you are jumping/branching to a word address so you concatenate it with a 0 bit at the LSB.

We have a case for each type where the output corresponds to each type of concatenation shown above in the image based on Immsrc. This can be seen below:

```systemverilog
  case (ImmSrc)
    // Immediate
    3'b000:  ImmExt = {{20{Imm[31]}}, {Imm[31:20]}};
    // Upper Immediate
    3'b001:  ImmExt = {{Imm[31:12]}, {12{1'b0}}};
    // Store
    3'b010:  ImmExt = {{20{Imm[31]}}, {Imm[31:25]}, {Imm[11:7]}};
    // Branch
    3'b011:  ImmExt = {{20{Imm[31]}}, {Imm[7]}, {Imm[30:25]}, {Imm[11:8]}, {1'b0}};
    // Jump      
    3'b100:  ImmExt = {{12{Imm[31]}}, {Imm[19:12]}, {Imm[20]}, {Imm[30:21]}, {1'b0}};
    // Default
    default: ImmExt = {32{1'b0}};
  endcase
```

# F1 machine code

### State Machine

One of the ways we tested the cpu works, was through writing an assembly language code to implement the F1 starting light algorithm from lab 3. The diagram for the state machine we were supposed to be implementing can be seen below (image taken from lab 3):

<img width="818" alt="Screenshot 2022-12-08 at 09 12 52" src="https://user-images.githubusercontent.com/116260803/206406136-199757c4-16d2-4f60-b2b5-da45afca4444.png">

Aside from executing the statemachine, we had to implement two different types of delay to ensure our program was as similar as possible to Lab 3. We implemented a constant delay between each red light and the next as well as a pseudo-random delay before all the random lights turn off and reset.
### Assembly Code Overview

The lfsr used in the random delay implementation is constantly running in the background (more on this in the random delay section). As soon as trigger is asserted manually (by pressing the 't' button or the rotary switch on the vbuddy) the lfsr stops (calculating the 'random' number) and the rest of the assembly code starts. We store the value of the statemachine in the register a0. In the first cycle after trigger is asserted, we perform a left shift on a0 and store it in a temporary register then add one and put it back in the original register a0. The reason we use the temporary register is because if we shift and store in a0 then later add to a0 we would have a temporary step where we have only shifted and not added that would be displayed, thus ruining our light display. We then implement a small constant delay (more on this below) between each red light and then jump back to the fsm and repeat as long as the value in a0 is not equal to s2, which is a register we have set to a constant value of 255 or 0xff, the value of state 8. Once the value is equal to 0xff and we are in state 8, we then implement the random delay and proceed to reset. 

### Constant delay between red lights

While testing, we thought that the lights were cycling through too quickly, not giving us a chance to properly see if our implementation was correct so we implemented a constant delay to allow us to see the light cycling better. To do this, we set a register s3 equal to a constant we decided on through trial and error. We then counted up from 0 in a register a1. We continued to count until the value in a1 was equal to the value in s3 before then resetting a1 and jumping back to the fsm subroutine.

``` assembly
count:
    addi  a1, a1, 0x1   ; counter++ 
    bne   a1, s3, count ; Loop if counting 
    addi  a1, zero, 0x0 ; reset counter 
    jalr  ra, ra, 0x0   ; return to fsm 
 ```

### Random delay implementation

We wanted to make our program as close as possible to the real F1 lights simulation. To do this, we needed to implement a random delay, however we knew that there was no way to get truly random results, so instead we implemented a pseudo-random delay through an lfsr. In the main, constantly running, we have 1 stored in register a3. We then perform a right shift by 3 bits, and store the value of a3 in a2. This basically puts the fourth bit of a3 (most significant bit) into the first bit of a2, allowing us to XOR the first and fourth bit, by XORing the registers (store result in a2). We then AND a2 with 0001, to turn the first three bits of a2 in to zeroes while maintaining the fourth bit. This is the only one we care about as we are XORing the first and fourth bit. We then shift a3 left by 1-bit , add a2 to a3 after the shift, and store in a3. The primitive polynomial for this lfsr is given by  $1$ + $X$ + $X^4$.
The lfsr runs untill the trigger is manually asserted ('t' is pressed or the rotary switch is pressed on the vbuddy) at which point the current value is decided on as the random number. The delay is then implemented as the random number, multiplied by the constant delay time between the red lights, it does this by performing the constant delay described above n times where n is the random number calculated by the lfsr.

``` assembly
mloop:
    beq  t0, s1, fsm    ; check trigger  
    ; lfsr starts 
    srli a2, a3, 0x3    ; send 4th bit to 1st bit 
    xor  a2, a2, a3     ; xor 4th bit and 1st bit 
    andi a2, a2, 0x1    ; remove other bits 
    slli a3, a3, 0x1    ; shift number left by 1 
    add  a3, a3, a2     ; add xor and shifted bits 
    andi a3, a3, 0xf    ; remove additional bits 
    ; lfsr ends 
    jal  ra, mloop      ; Loop  
    
delay:
    beq  a4, a3, reset  ; if delay counter is finished reset 
    jal  ra, count      ; jump to counter 
    addi a4, a4, 0x1    ; increment delay counter 
    jal  ra, delay      ; Loop 
    
```

# Make & Run Shell Scripts

Originially, we planned to have a seperate shell script for our Pipeline and Single Cycle CPU and use a Makefile which contained a different make our different assembly programs using the files provided for us and adjusting them slightly. This worked initially but required us to manually change the name of the memory files as well as the shell scripts to access the correct assembly codes. 

This felt clunky and especially slow when testing our programs. To combat this, we had the idea a sepearate shell script called make.sh which would now take in arguments in when the file is ran on the terminal. 

After some research we found a nice way to do this using bash commands to take the arguments using the $1, $2, $3, if statements and sed commands. 

Here are a few snippets from the make file

```bash
# Arguments
Instr="$2"

# Error Check
if [ "$Instr" == "PDFSC" ] || [ "$Instr" == "PDFPL" ] || [ "$Instr" == "F1SC" ] || [ "$Instr" == "F1PL" ]; then
    let "Pass++"
else 
    echo "ERROR: Cannot find file: $Instr.s"
fi

# Replace mem and instruction files
sed -i "s/\$r.*/\$readmemh(\"\.\/test\/Memory\/$Mem\.mem\", RAM, 32'h10000);/" rtl/$Dir/DataMemory.sv

# Format testbench
if [[ "$Instr" == "PDF"* ]]; then
    sed -i "s/START F1 \*\//START F1 \/\//" cpu_tb.cpp
    sed -i "s/START PDF \/\//START PDF \*\//" cpu_tb.cpp
```

These show generally how the make file works, with the exclusion of the assembler as that is taken directly from the given Makefile but extracted into a shell script. The run.sh file is exactly like the old doit.sh but in with -I to allow the verilator command to iterate over the following directory: rtl/$Dir where Dir is a variable read as $1 or the first argument after the filname.

### Example code

```bash
verilator -Irtl/$Dir -Wall --cc --prof-cfuncs -CFLAGS -DVL_DEBUG --trace cpu.sv --exe cpu_tb.cpp
```

### Effective code if ran with ./run.sh SingleCycle

for example ./run.sh SingleCycle would run:
```bash
verilator -Irtl/SingleCycle -Wall --cc --prof-cfuncs -CFLAGS -DVL_DEBUG --trace cpu.sv --exe cpu_tb.cpp
```

# Reflection

Overall, I believe this was an extremely beneficial project as it has taught much not only with the course, system verilog and the RISC-V architecture, but also allowed my curiosity to explore multiple avenues such as shell scripting, bash, git, and much more. It was amazing working as a team communicating and coordinating between the members and each module, especially when things were going wrong. Going forward I would like to use git and github more properly such as by using branches to seperate each others work on the project and merging when necessary, rather than sharing files locally through messages and email as we have done. Furthermore, I would have liked to have had the time to get onto cache as well as potentially adding a hazard unit to our pipelined cpu. 


# iac-riscv-cw-32
## Introduction

In the rtl folder you can find all the files we have worked and uploaded during the course of the project. These include the base folder, which has the lab 4 CPU built before we received the project brief. Also included in the rtl folder, is our adapted base cpu, called single-cycle, for our lab 5 as well as the pipelined version and a read me describing what each person has worked on. The test folder contains all our test files and a readme explaining the results we saw.
This readme file describes how we implemented our cpu and how it works.

## Single-Cycle CPU
To explain how we implemented the full single cycle CPU, we will talk about it in parts. The picture below shows the schematic of the cpu with a few extra multiplexors which we will explain later.

<img width="514" alt="Screenshot 2022-12-08 at 13 41 18" src="https://user-images.githubusercontent.com/116260803/206461093-a04f7036-d5ce-47a8-9e6b-5642c93bab6f.png">

### PC Module

The PC module is clocked, meaning that PC next becomes PC on the rising edge of the next clock cycle.
The instruction memory is byte addressed so every cycle, pc increments by 4 as one word, is 4 bytes. PC decides which memory instruction is being read from the ROM which has $2^{28}$ memory locations. We implemented a wire called PC target which is used when doing branches or jumps, to tell PC where to jump/branch to. 
The Pc decides whether to jump to a location or increment by four as usual through a mux which has inputs PC target and PC + 4 and a select jump reg, which goes high (thus selecting PC target) when doing a jump/branch. 

Once we read from the ROM, the output of PC module is a concatenation of PC instructions to form a word therefore making a full instruction. The instruction is then sent to the control, sign extend and ALU units. 

### Control Unit

<img width="651" alt="Screenshot 2022-12-12 at 12 25 53" src="https://user-images.githubusercontent.com/116260803/207044724-101dbd4e-a93d-43af-846f-a789ab644c73.png">

As seen in the picture above (taken from lecture 7), the control unit takes in 4 inputs, the zero flag (used for branches) , opcode (determines which type of instruction we are doing), funct3 (tells us which ALU instruction we are doing), and funct7 bit 5 (this distinguishes between arithmetic/logical shifts and add/sub.

<img width="662" alt="Screenshot 2022-12-12 at 12 35 52" src="https://user-images.githubusercontent.com/116260803/207046709-8aafcf19-7cbc-48a6-9f66-cbe0b43898f8.png">

The image (Also taken from lecture 7) above now shows a lower level, more in-depth view of the control unit. We can clearly see that it is now split into the Main decoder, which decodes opblock instuctions, and ALU decoder which decodes funct3 and funct7 bit 5. We can also see that the zero flag and branch signal. 
We want PCSRC to be equal to 1 when the LSB of funct3 is 0 and the zero flag to be one or the LSB of funct3 to be 1 and the zero flag to be 0. This is the equivelant of XOR'ing the LSB of funct3 and the zero flag. We then and this with the branch signal to ensure thatit is also a flag before PCSRC goes high.

Now, Let's look at the Main decoder, implemented as maindecoder.sv on this git. We defined all our defaults at the beginning and based on which instruction we are executing, we alter the appropriate control signal from default. An example of this is seen below using the branch instruction:

```verilog
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
The ALU src is set to 0 so that in our ALU we read straight from a register. The ALUsrc acts as a select to a mux just before the ALU thus deciding what goes into the ALU.
Finally, since it is a branch instruction we set branch signal equal to 1 so that we can change PCSRC as talked about above.

Moving on to look at the ALU decoder (ALUdecoder.sv), There we implement 3 types of instructions: Register & Immediate, load/store & Branch.

Register & immediate: 

As long as it's not not a load or a store function, the output is the same instruction for both register and immediate types, it is based on funct3, funct7 bit 5 and opcode bit 5.

Load/Store: 

If the instruction is a load or a store, we make it an add instruction because in the risc-v instruction set, we add a register and an immediate to get the memory address of what we are storing. 
Here we also also added an extra output called Type which tells us if we are loading or stroing byte, half-word, byte unsigned, half unsigned. We set this to be funct3 as they're the same for laod and store.

Branch: 

We have 6 branch instructions. For beq and bne, we check the zero flag coming from the the ALU (determined using subtraction), it should be zero. All the other branches, have MSB 1 in funct3, so we use a mux to determine whether we do a sub in ALU or if we do less than signed/unsigned. This is decided off the middle bit of funct3.





### Sign Extend Unit

### ALU 



## F1 machine code

One of the ways we tested the cpu works, was through writing an assembly language code to implement the F1 starting light algorithm from lab 3. The diagram for the state machine we were supposed to be implementing can be seen below (image taken from lab 3):

<img width="818" alt="Screenshot 2022-12-08 at 09 12 52" src="https://user-images.githubusercontent.com/116260803/206406136-199757c4-16d2-4f60-b2b5-da45afca4444.png">

Aside from executing the statemachine, we had to implement two different types of delay to ensure our program was as similar as possible to Lab 3. We implemented a constant delay between each red light and the next as well as a pseudo-random delay before all the random lights turn off and reset.
### Assembly Code Overview

The lfsr used in the random delay implementation is constantly running in the background (more on this in the random delay section). As soon as trigger is asserted manually (by pressing the 't' button or the rotary switch on the vbuddy) the lfsr stops (calculating the 'random' number) and the rest of the assembly code starts. We store the value of the statemachine in the register a0. In the first cycle after trigger is asserted, we perform a left shift on a0 and store it in a temporary register then add one and put it back in the original register a0. The reason we use the temporary register is because if we shift and store in a0 then later add to a0 we would have a temporary step where we have only shifted and not added that would be displayed, thus ruining our light display. We then implement a small constant delay (more on this below) between each red light and then jump back to the fsm and repeat as long as the value in a0 is not equal to s2, which is a register we have set to a constant value of 255 or 0xff, the value of state 8. Once the value is equal to 0xff and we are in state 8, we then implement the random delay and proceed to reset. 

### Constant delay between red lights

While testing, we thought that the lights were cycling through too quickly, not giving us a chance to properly see if our implementation was correct so we implemented a constant delay to allow us to see the light cycling better. To do this, we set a register s3 equal to a constant we decided on through trial and error. We then counted up from 0 in a register a1. We continued to count untill the value in a1 was equal to the value in s3 before then resetting a1 and jumping back to the fsm subroutine.

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


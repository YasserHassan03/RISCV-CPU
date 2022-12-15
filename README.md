# iac-riscv-cw-32
## Introduction

In the rtl folder you can find all the files we have worked and uploaded during the course of the project. These include the base folder, which has the lab 4 CPU built before we received the project brief. Also included in the rtl folder, is our adapted base cpu, called single-cycle, for our lab 5 as well as the pipelined version and a read me describing what each person has worked on. The test folder contains all our test files and a readme explaining the results we saw. You can find our individual personal statements, in the personal statement folder.
This readme file describes how we implemented our cpu and how it works.

## Single-Cycle CPU
To explain how we implemented the full single cycle CPU, we will talk about it in parts. The picture below shows the schematic of the cpu with a few extra multiplexors which we will explain later.

<img width="514" alt="Screenshot 2022-12-08 at 13 41 18" src="https://user-images.githubusercontent.com/116260803/206461093-a04f7036-d5ce-47a8-9e6b-5642c93bab6f.png">

### PC Module

The PC module is clocked, meaning that PC next becomes PC on the rising edge of the next clock cycle.
The instruction memory is little endian byte addressed so every cycle, PC increments by 4 as one word (4 bytes). PC decides which memory instruction is being read from the ROM which we set to have $2^{28}$ memory locations as the compiler throws an error for anything higher. We implemented a wire called PCtarget which is used when doing branches or jal, to tell PC where to jump/branch to . 
The PC decides whether to jump to a location or increment by four as usual through a mux which has inputs PCtarget and PC + 4 and a select PCsrc, which goes high (thus selecting PC target) when doing a jump/branch. 

Once we read from the ROM, the output of PC module is a concatenation of PC instructions to form a word therefore making a full instruction. The instruction is then sent to the control, sign extend and ALU units. 

### Control Unit

<img width="651" alt="Screenshot 2022-12-12 at 12 25 53" src="https://user-images.githubusercontent.com/116260803/207044724-101dbd4e-a93d-43af-846f-a789ab644c73.png">

As seen in the picture above (taken from lecture 7), the control unit takes in 4 inputs, the zero flag (used for branches) , opcode (determines which type of instruction we are doing), funct3 (tells us which ALU instruction we are doing), and funct7 bit 5 (this distinguishes between arithmetic/logical shifts and add/sub.

<img width="662" alt="Screenshot 2022-12-12 at 12 35 52" src="https://user-images.githubusercontent.com/116260803/207046709-8aafcf19-7cbc-48a6-9f66-cbe0b43898f8.png">

The image (Also taken from lecture 7) above now shows a lower level, more in-depth view of the control unit. We can clearly see that it is now split into the Main decoder, which decodes opblock instuctions, and ALU decoder which decodes funct3 and funct7 bit 5. We can also see that the zero flag is *AND'ed* with the branch signal to result in PCSRC. 
We want PCSRC to be equal to 1 when the LSB of funct3 is 0 and the Zero flag is 1 or the when LSB of funct3 is 1 and the Zero flag is 0. This is the equivelant of *XOR'ing* the LSB of funct3 and the Zero flag. We then *AND* this with the branch signal to ensure that it is also a flag before PCSRC goes high.

Now, let's look at the Main decoder, implemented as maindecoder.sv on this git. We defined all our defaults at the beginning and based on which instruction we are executing, we alter the appropriate control signal from default. An example of this is seen below using the branch instruction:

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
The ALUsrc is set to 0 so that in our ALU we can compare two register values. The ALUsrc acts as a select to a mux just before the ALU thus deciding what goes into the ALU.
Finally, since it is a branch instruction we set branch signal equal to 1 so that we can change PCSRC as talked about above.

Moving on to look at the ALU decoder (ALUdecoder.sv), There we implement 3 types of instructions: Register & Immediate, load/store & Branch.

Register & immediate: 

As long as it's not a load or a store function, the ALUcontrol is the same instruction for both register and immediate types, and is based on funct3, funct7 bit 5 and opcode bit 5.

Load/Store: 

If the instruction is a load or a store, we make it an add instruction because in the risc-v instruction set, we add a register and an immediate to get the memory address of what we are storing. 
Here we also also added an extra output called Type which tells us if we are loading or storing byte, half-word, word, byte unsigned, half unsigned. We set this to be funct3 as they're the same for laod and store.

Branch: 

We have 6 branch instructions. For beq and bne, we check the zero flag coming from the the ALU (determined using subtraction), it should be zero. All the other branches, have MSB 1 in funct3, so we use a mux to determine whether we do a sub in ALU or if we do less than signed/unsigned. This is decided off the middle bit of funct3.

### Sign Extend Unit

Each Imm set-up is different for each type of instruction (I,U,S,B,J) as seen below (from lecture 6):

<img width="1339" alt="Screenshot 2022-12-12 at 14 07 51" src="https://user-images.githubusercontent.com/116260803/207066709-afed76d9-bc9a-47de-9cc5-10c0e58c0d20.png">

Note: for jumps and branch, our immediate starts from 1 not 0 because you are jumping/branching to a word address so you concatenate it with a 0 bit at the LSB.

We have a case for each type where the output corresponds to each type of concatenation shown above in the image based on Immsrc.

### ALU 
The ALU top module consists of the Arithmetic Logic Unit and register file. The register file implements the registers of the processor. The main input to the ALU is ALUControl which determines which operation is supposed to be performed. We used a 4 bit wire in order to have enough binary combinations to distinguish between each desired operation. This was required to choose between ADD/SUB operations (which both have 000 as the 3 LSBs) and the logical/arithmetic right shift operations (which both have 101 as the 3 LSBs). The MSB is used to choose between these and comes from funct7 bit 5. The additional input bit overcame the problem of not having enough combinations for the different operations required.
This enabled the different cases to be implemented easily as shown below:

```verilog
always_comb begin
    case (ALUControl[2:0])
      // Add Sub
      3'b000:  ALUResult = ALUControl[3] ? SrcA - SrcB : SrcA + SrcB;
      // Shift Left    
      3'b001:  ALUResult = SrcA << SrcB[4:0];
      // Set Less Than (Signed) 
      3'b010:  ALUResult = {{31{1'b0}}, {signed'(SrcA) < signed'(SrcB)}};
      // Set Less Than (Unsigned)
      3'b011:  ALUResult = {{31{1'b0}}, {SrcA < SrcB}};
      // XOR
      3'b100:  ALUResult = SrcA ^ SrcB;
      // Shift Right (Arithmetic/Logical) 
      3'b101:  ALUResult = ALUControl[3] ? $signed($signed(SrcA) >>> SrcB[4:0]) : SrcA >> SrcB[4:0];
      // OR 
      3'b110:  ALUResult = SrcA | SrcB;
      // AND
      3'b111:  ALUResult = SrcA & SrcB;
      // Default
      default: ALUResult = 32'b0;
    endcase
    Zero = (ALUResult == 0);
  end

```

The inputs SRCA and SRCB come from the register file and are the 32 bit values that are operated on by the ALU depending on the operation selected.
The register file is a clocked multi-port array which is used to load/store values. We used parameters for the address and data widths in order to be able to change them easily if we wanted to. By default the size of the register file is 32 by 32 bits. The outputs RD1 and RD2 are set to be the value held at address A1 and A2 respectively. These adress values are obtained from the instruction bits 19:15 and 24:20. Input A3 is used to specify the address where to write the input value WD3 (Result) if the input to the write enable (WE3) is high. The input trigger causes the value at register t0 (address 5) to be set to 1. The output a0 is the value held at register 10.

Finally the top level ALU module includes additional multiplexers which can enable additional instructions. The mux for ImmRes chooses the sign extended value when ImmUppSrc is high (this would be the case for LUI instructions) and bypasses the ALU. Otherwise the result is read from the ALU as normal. THe WD3 mux takes in PC+4 and ImmRes with jump as the select. If jump is high then the Write Data is PC+4 as this needs to be stored in the register for JAL or JLR instructions (as a sort of return address) otherwise the write data remains as normal. The SrcA mux enables the upper immediate to be added to the program counter which is an AUIP instruction. This happens if the PCUppSrc select is high. The SrcB mux decides if the input to the ALU comes from the register or the immediate operand. So the select ALUSrc is used to distinguish between register or immediate operations.

The main challenge in the ALU section was to find a way to be able to distinguish between the RISCV instructions and implement logic to cause the ALU to behave accordingly.




## F1 machine code

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


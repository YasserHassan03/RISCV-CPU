## Introduction:

I was mainly in charge of the ALU section of the CPU in both the pipeline and single-cycle versions as well as the data memory.sv file and the register file. I was also mainly responsible for writing up the readme section in the testing folder where we describe how we know if our tests work.
However due to the interconnected nature of the project and the whole groups willingness to work together and maximise our learning of the whole cpu and the designing process I collaborated with other people on the parts they were main contributor for as well as others contributing to what I was principle contributor to.

## ALU 
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

Finally the top level ALU module also includes additional multiplexers which can enable additional instructions. The mux for ImmRes chooses the sign extended value when ImmUppSrc is high (this would be the case for LUI instructions) and bypasses the ALU. Otherwise the result is read from the ALU as normal. THe WD3 mux takes in PC+4 and ImmRes with jump as the select. If jump is high then the Write Data is PC+4 as this needs to be stored in the register for JAL or JLR instructions (as a sort of return address) otherwise the write data remains as normal. The SrcA mux enables the upper immediate to be added to the program counter which is an AUIP instruction. This happens if the PCUppSrc select is high. The SrcB mux decides if the input to the ALU comes from the register or the immediate operand. So the select ALUSrc is used to distinguish between register or immediate operations.

The main challenge in the ALU section was to find a way to deal with set less than instructions which had issues regarding diffrentiating between the signed and unsigned value. Originally, we used logic to calculate signed less than using top bits from both inputs and the unsigned less than operator seen in this [comit](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/commit/d7b0411ff0c59daaed8e4f09404eff5eb6a275b0). We fixed this and made it a lot easier, by casting 2 inputs as signed numbers using `signed'` as can be seen [here](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/commit/bbfd51d27f4858567424f68525cc031a3dfeb6af)

## Register file

Initially when writing the the register file, we would just check if the write enable was 1and then write to a3 our write address :

``` verilog
 if (WE3) REG_FILE[A3] <= WD3;
```
However while testing , we ran into trouble especially with a ret instruction which would end up writing to our zero register. To fix this, we quite simply decided to check that both the write enable is one and that the register we are writing to is not a zero register. This was done as follows:

```verilog
 if (WE3 & A3 != 0) REG_FILE[A3] <= WD3;
```
## Data memory

In data memory all we do is specify which file we are reading from and then put each byte from the instruction word into a specific pasrt of the write address. We had to make sure when testing that we start writing memory at the desired address specified by the memory map. Initially as can be seen in this [commit](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/commit/560159f1c84dba04be77ff66af514d4028afd2f9#diff-09e7f6ae93159d1711a1d00f971f66a606e56e2357adf7d03bf1256bad402695) we had it in big endian. However, due to the reference program being in little endian, we had to change the file to comply like [this](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/commit/395c80ac38ef29dd77dce1344d4ac235b984049a)

## pipelining

### ExeMem flip flop

For pipelining I wrote the Exemem.ff file to comply with the following:

<img width="451" alt="Screenshot 2022-12-16 at 11 32 59" src="https://user-images.githubusercontent.com/116260803/208089347-57087103-6b8d-4ef5-9ab0-6438137ce71e.png">

We stored all the inputs and then 'held' them in the flipflop for one cycle, then 'release' them. The hardest part of the pipelining was rewiring the components so that they complied with the registers.

### Changes to rest of files

We removed ALU top because, initially as can be seen [here](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/commit/90622539232c0311c49b4e08d6f7cfbe4f5b52fd#diff-2f3497d1fa6d969dbae329e73929aad83199e038fa02e4ad263cd3e78c84be7b) we had alu and register file in ALUtop. However when we pipelined, we had to sepereate register file and ALU module ad they were seperated by the decode-execute register. So we therefore deleted the file and placed them both in [PC top](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/commit/5e083d5af25077a57f939ea142b8b65c45ea07a3). We also changed the register file to write on negedge rather than posedge so that the instruction after the write doesnt have to wait an extra cycle thus removing an extra nop.

### Adding Nops to pdf file

I was also a lead in adding nops to the pdf assmebly file to allow our pipeline program to be tested.

We added nops for two reasons: data hazards and control hazards. We had Control hazards whenever we did a branch or a jump, so we always added two nops straight after to ensure that jump/branch had enough time to reach the PCsrc logic and return to PC counter before another instruction is read in. Whereas Data hazards appeared whenever we tried accessing/fetching from a register which hadn't finished it's write cycle yet. 

## Reflection

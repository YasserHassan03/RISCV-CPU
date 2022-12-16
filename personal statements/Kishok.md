
# Kishok Sivakumaran: Personal Statement
## Introduction
In this project, my primary role involved the design of the top level SystemVerilog files that connect various components into higher level modules. In addition to this, I was responsible for the testing of the CPU. Despite each team member being given an assigned section of the task, we collaborated with each other on our individual subdivisions to solve problems that arose as well as communicate how each of our modules would interact with each other.

## ALU Top

The ALU top module is responsible for connecting the ALU, register file, data memory and 2 MUXs together. This was done for the lab 4 processor in accordance with the schematic. This then carried on into the single cycle CPU design where we added 2 additional MUXes for the WD3 inputs as well as a MUX for SrcA to the ALU. These changes can be seen bellow: 

### Single Cycle Result -> WD3 MUXes 

```sv
always_comb begin
    ImmRes = ImmUppSrc ? ImmExt : Result;
    WD3 = Jump ? PC + 4 : ImmRes;
end
```

### Single Cycle RD1 -> SrcA MUX

```sv
assign SrcA = PCUppSrc ? PC : RD1;
```

## Control Unit

<img height="400" alt="Screenshot 2022-12-12 at 12 35 52" src="https://user-images.githubusercontent.com/116260803/207046709-8aafcf19-7cbc-48a6-9f66-cbe0b43898f8.png">

The control unit module is responsible for tying together the 2 main components that make up the control unit: the main decoder and the ALU decoder. This module was fairly simple to design since there are only 2 internal wires linking everything together being ALUOp and Branch which can be seen in the image above. 

Going from our Base CPU to the Single Cycle CPU, quickly realised that there were many instructions that we did not account for yet. This required additional control signals namely; Jump, JumpReg, PCUppSrc and ImmUppSrc. The new signals to be added to the design for the single cycle CPU was adequately discusssed and decided upon. 

It was noticed that the PCSrc logic didn't account for branch instructions except beq and bne due to they way in which the Zero flag was calculated. This was fixed by adding the MSB of funct3 as a third input to the XOR gate. 

```sv
assign PCSrc = (Branch & (funct3[0] ^ funct3[2] ^ Zero)) || Jump;
```

## Memory Top

The memory top file is used to group together the store, load and data memories in order to clean up the design, make it more modular for simpler testing and a more organised final CPU top level design. This was done in order to make the function of the CPU easier to understand for the rest of the team to improve efficiency in implementation.

The data memory module can only write and load full words. To remedy this, we made 2 additional modules (```StoreMemory.sv``` and ```LoadMemory.sv```) before and after the data memory (RAM) module. These are used to format the data to be written or read respectively to memory.

Since the data memory can only read in words of 4 bytes, the last 2 bits of the address were replaced with 0s. This ensures that only address values that are multiples of 4 are read/ written to.

### Memory Address Inputs

```sv
DataMemory DM (
    .A  ({{ALUResult[31:2]}, {2'b00}}),
```

Finally, we added a MUX to determine the Result output, which can either be the output of the ALU (```ALUResult```) or the data that is read from memory (```Data```).

### Single Cycle Data -> Result MUX

```sv 
assign Result = ResultSrc ? Data : ALUResult;
```

## CPU Top Level Design

The overall top level design of the RISC-V CPU is comprised of the following modules: PC Top, Instruction Memory, Control Unit, Sign Extend and ALU Top, Memory Top. The appropriate wires to connect these modules have been created and utilised. This facilitated by the grouping of smaller related components to produce larger, simpler modules to reduce complexity. 

## Testbench Program

The testbench program is similar to the testbench made in the week 4 labs, in which the program runs the through clock cycles and allows the CPU to execute the instructions stored in the instruction memory. The program also initialises the trace dump to a vcd file. We made 2 variations of the testbench for each program we tested, the probability density function and the F1 light sequence. 
For the probability density function:
```cpp
if (simcyc == 1500000) std::cout << "PDF Loaded to RAM successfully\n";
if (simcyc>1500000 && simcyc% 9 == 0) {
      vbdPlot(cpu->a0,0,255);
} 
```

The if statement is used to plot the results of the CPU between clock cycles 0 and 1500000 in intervals of 9 cycles with the VbdPlot function. NOTE: Points are not plotted after every clock cycle to improve the speed at which the program runs as plotting points slows down execution considerably. 
The clock runs for 1500000 cycles in order to ensure that all of the instructions in the instruction memory have been executed. 

For the F1 light sequence program:

```cpp
cpu-> trigger = vbdFlag() || vbdGetkey() == 't'; 
vbdBar(cpu->a0);
vbdCycle(simcyc);
```

```VbdSetMode(1)``` is used so that the trigger input is automatically toggled low after it has been read as high.

## Pipelining

During pipelining we worked as a team to modify and redesign the pipelined schematic provided to us in lectures. This was necessary as the schematic provided was incomplete and so we had to analyse the schematic and compare it against the requirements to pipeline the CPU, like adding registers to each stage, and adding/extending signals so they can be saved for the next stage to use after completing the previous instruction. An important modification that was made was the dismantling of ```ALUTop.sv``` into its individual components (register file, ALU and data memory).

### ALUtop Dismantling

#### Decode Stage

```sv
// Register File Module
RegisterFile RF (
    .CLK(CLK),
    .trigger(trigger),
    .WE3(RegWriteW),
    .A1 (InstrD[19:15]),
    .A2 (InstrD[24:20]),
    .A3 (RdW),
    .WD3(ResultW),
    .RD1(RD1Din),
    .RD2(RD2D),
    .a0 (a0)
);

// RD1D MUX 
assign RD1D = RD1SrcD ? PCD : RD1Din; 
```

#### Execute Stage
```sv
// SrcB MUX
assign SrcBE = ALUSrcE ? ImmExtE : RD2E;

// ALU Module
ALU ALU (
    .ALUControl(ALUControlE),
    .SrcA(RD1E),
    .SrcB(SrcBE),
    .ALUResult(ALUResultE),
    .Zero(ZeroE)
);

// PCSrc Logic
assign PCSrcE = (BranchE & (funct3MSBE ^ (funct3LSBE ^ ZeroE))) || JumpE;

// PCTarget Logic
assign PCTargetE = ImmExtE + PCE;
```

## Updated Pipeline Schematic
<img height="400" src="https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/blob/main/personal%20statements/images/PipelineUpdatedSchematic.png">


## Reflections
Overall, I am satisfied with the results of this project. Tasks were well delegated and our team were able to communicate with each other and as a result we joined our various backgrounds and expertise to tackle individual issues we stumbled upon as well as cover for areas in which we lacked. While we may not have been able to implement cache or the other extensions, I feel that the demands of this project provided me with the push I needed to prompt a more enriched understanding of the RISC-V architecture and how certain improvements can be made to improve efficiency in practice (i.e. pipelining, cache, etc). Had there been more time, I would have liked to have played around with git commands more so that I'm more confident managing code with collaborative projects such as this one as opposed to my fairly surface level understanding at the time of writing this.
## 




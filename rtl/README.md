## Group statement:

Due to the nature of the project being interconnected and the willingness and eagerness of everyone in the group to maximise learning rather than limit ourselves to one part of the cpu, we decided to work together on the majority of the project but have certain people responsible/ in charge for certain aspescts, therefore communication was a major part of our group's dynamic.

| Module          | James        | Yasser         | Kishok     |Ahmad    |
| :---            |    :----:    |          :---: |:---:       |-----:   |
| ALUtop.sv       |    x         |    x           | *          |  x      |
| ControlUnit.sv  |        x     |     x          |  *         |  x      |
|Memorytop.sv     |         x    |     x          |  *         |  x      |
|cpu.sv           |          x   |     x          |  *         |  x      |
|cpu_tb.cpp       |         x    |     x          |  *         |  x      |
|LoadMemory.sv    |   *          |     x          |  x         |   x     |
|StoreMemory.sv   |   *          |     x          |  x         |   x     |
|PCReg.sv         |   *          |      x         |  x         |  x      |
|PCTop.sv         |   *          |      x         |  x         |  x      |
|InstrMemory.mem  |   *          |      x         |   x        |  x      |
|InstrMemory.sv   |   *          |     x          |  x         |  x      |
|ALU.sv           |         x    |  *             |   x        |  x      |
|RegisterFile.sv  |         x    |  *             |    x       |  x      |
|DataMemory.mem   |         x    |  *             |    x       |  x      |
|DataMemory.sv    |         x    |  *             |    x       |  x      |
|SignExtend.sv    |  x           |      x         |    x       |  *      |
|ALUDecode.sv     |  x           |      x         |    x       |  *      |
|MainDecoder.sv   |  x           |      x         |    x       |  *      |
|F1SC.s           |  x           |      x         |    x       |  *      |
|make.sh          |  x           |      x         |    x       |  *      |
|run.sh           |  x           |      x         |    x       |  *      |


x =Also helped        * =Principle Contributor

Who was in charge of what is listed below:

### Kishok: 
I was mainly in charge of the top level modules and testing, these included the following files: 

-ALUtop.sv 

-ControlUnit.sv 

-Memorytop.sv 

-cpu.sv 

-cpu_tb.cpp

### James: 
I was mainly in charge of PC and memory including the following: 

-LoadMemory.sv 

-StoreMemory.sv 

-PCReg.sv 

-PCTop.sv 

-InstrMemory.mem 

-IsntrMemory.sv

### Yasser: 
As well as being the main editor on the readme files, I was mainly in charge of the Alu and the readme including: 
 
 -ALU.sv 
 
 -RegisterFile.sv 
 
 -DataMemory.mem 
 
 -DataMemory.sv 
 

### Ahmad: 
I was mainly in charge of the control and sign extend unit as well as the F1 machine code including: 

-SignExtend.sv 

-ALUDecode.sv 

-MainDecoder.sv 

-F1SC.s

-make.sh

-run.sh

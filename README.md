# iac-riscv-cw-32
## Introduction

In the rtl folder you can find all the files we have worked on and uploaded during the course of the project. These include the base folder, which has the lab 4 CPU built before we received the project brief. Also included in the rtl folder, is our adapted base cpu, called single-cycle, for our lab 5 as well as the pipelined version and a read me describing what each person has worked on. The test folder contains all our test files and a readme explaining the results we saw. You can find our individual personal statements, in the personal statement folder.
This readme file describes how we implemented our cpu and how it works.

## How to run our program

You need to run our program in two steps. We have assumed that you are testing using an M1 mac. To run it please make sure you have installed gawk you can do this by doing: 

```shell 
brew install gawk
```
Otherwise if you are on Windows please run using this previous [comit](https://github.com/EIE2-IAC-Labs/iac-riscv-cw-32/commit/b7c1a90331fcb9cff28e1bed93c3625fc68cc35f) for the make.sh file. We have used both in our testing and they both work fine provided that you install gawk if you are on mac (more on this in Ahmad's readme).

The first step to run our program is to run 
``` shell
 ./make.sh (type of program goes here) (assembly file) (memory file when using pdf)
```
These are the possibilities for type of program (all of which are case sensitive: SingleCycle, Pipeline

The possibilities for assemble file are: F1SC (corresponding to single cycle F1), F1PL (corresponding to a pipelined F1), PDFSC (corresponds to pdf single cycle) and PDFPL (corresponding to a pipelined pdf)

Finally the possibilities for memory file are: noisy, sine, gaussian, triangle

The second step of our program is running the file you made like this :

```shell
./run.sh (type of program, same as above)
```

For example to run single cycle F1 it would be as follows:

``` shell
 ./make.sh SingleCycle F1SC 
```

Followed by:

```shell
./run.sh SingleCycle
```

Whereas to run Gaussian pipelined it would look like this:

``` shell
 ./make.sh Pipeline PDFPL gaussian 
```
followed by :

```shell
./run.sh Pipeline
```

## Who did what:

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
|ExeMemmff        |              |     *          |            |         |
|DecExeff         |  *           |                |            |         |
|FetchDecff       |              |                |            |  *      |
|MemWriteff       |              |                |   *        |         | 
|F1PL             |  *           |  x             |   x        |   x     |
|PDFPL            |  x           |   *            |   x        |  x      |   

x =Also helped        * =Principle Contributor

Some More Detail can be found in RTL folder


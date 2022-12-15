#!/bin/sh
# use chmod +x to make file executeable 

# cleanup
make clean

# Convert Assembly to Machine code
make reference
make F1Lights

# run Verilator to translate Verilog into C++, including C++ testbench
verilator -Irtl/Latest -Wall --cc --prof-cfuncs -CFLAGS -DVL_DEBUG --trace cpu.sv --exe cpu_tb.cpp

# build C++ project via make automatically generated by Verilator
make -j -C obj_dir/ -f Vcpu.mk Vcpu

# run executable simulation file
echo "\nRunning simulation"
obj_dir/Vcpu
echo "\nSimulation completed"
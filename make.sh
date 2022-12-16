#!/bin/bash
# brew install gawk

# Arguments
Dir=$1
Instr=$2
Mem=$3

# Error Check
Pass=0

if  [ "$Dir" == "SingleCycle" ] || [ "$Dir" == "Latest" ] || [ "$Dir" == "Pipeline" ]; then
    let "Pass++"
else 
    echo "ERROR: Cannot find directory: $Dir/"
fi

if [ "$Instr" == "PDFSC" ] || [ "$Instr" == "PDFPL" ] || [ "$Instr" == "F1SC" ] || [ "$Instr" == "F1PL" ]; then
    let "Pass++"
else 
    echo "ERROR: Cannot find file: $Instr.s"
fi


if [ "$Mem" == "sine" ] || [ "$Mem" == "triangle" ] || [ "$Mem" == "gaussian" ] || [ "$Mem" == "noisy" ] || [ "$Mem" == "" ]; then
    let "Pass++"
else 
    echo "ERROR: Cannot find file: $Mem.mem"
fi

# Cleanup
rm -f -rf **/**/*.hex **/**/*.asm **/**/*.out **/**/*.bin *.vcd *.out obj_dir

# Pass Error Check
if [ "$Pass" == "3" ]; then

    # Convert Assembly to Machine code
    riscv64-unknown-elf-as -R -march=rv32im -mabi=ilp32 -o test/Memory/$Instr.out test/Assembly/$Instr.s
    riscv64-unknown-elf-ld -melf32lriscv -e 0xBFC00000 -Ttext 0xBFC00000 -o test/Memory/$Instr.out.reloc test/Memory/$Instr.out
    riscv64-unknown-elf-objcopy -O binary -j .text test/Memory/$Instr.out.reloc test/Memory/$Instr.bin
    riscv64-unknown-elf-objdump -D -S -l -F -Mno-aliases test/Memory/$Instr.out.reloc > test/Assembly/$Instr.asm
    od -v -An -t x1 test/Memory/$Instr.bin | tr -s '\n' | awk '{$Instr=$Instr};1' > test/Memory/$Instr.hex
    rm test/Memory/$Instr.out
    rm test/Memory/$Instr.out.reloc
    rm test/Memory/$Instr.bin
    rm test/Assembly/$Instr.asm

    # Replace mem and instruction files
    sed -i '' "s/\$r.*/\$readmemh(\"\.\/test\/Memory\/$Mem\.mem\", RAM, 32'h10000);/" rtl/$Dir/DataMemory.sv
    sed -i '' "s/\$r.*/\$readmemh(\"\.\/test\/Memory\/$Instr\.hex\", ROM);/" rtl/$Dir/InstrMemory.sv

    # Format testbench
    if [[ "$Instr" == "PDF"* ]]; then
        sed -i '' "s/START F1 \*\//START F1 \/\//" cpu_tb.cpp
        sed -i '' "s/START PDF \/\//START PDF \*\//" cpu_tb.cpp
    elif [[ "$Instr" == "F1"* ]]; then
        sed -i '' "s/START F1 \/\//START F1 \*\//" cpu_tb.cpp
        sed -i '' "s/START PDF \*\//START PDF \/\//" cpu_tb.cpp
    else
        sed -i '' "s/START F1 \*\//START F1 \/\//" cpu_tb.cpp
        sed -i ''"s/START PDF \*\//START PDF \/\//" cpu_tb.cpp
    fi

    echo "Make Complete"
else
    echo "ERROR: Make Failed"
    echo "$Pass" 
fi

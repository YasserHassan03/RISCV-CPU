# Make file to assembly RISC-V assembly language program(s) in myprog folder
#   test. relocate instruction to start at 0xBFC00000
#   test. output hex file ready to be read into instruction memory
#
clean:
	@rm -f **/**/pdf.hex **/**/pdf.asm **/**/pdf.out **/**/pdf.bin
	@rm -f **/**/F1Lights.hex **/**/F1Lights.asm **/**/F1Lights.out **/**/F1Lights.bin

reference: test/Assembly/pdf.s
	@riscv64-unknown-elf-as -R -march=rv32im -mabi=ilp32 -o test/Memory/pdf.out test/Assembly/pdf.s
	@riscv64-unknown-elf-ld -melf32lriscv -e 0xBFC00000 -Ttext 0xBFC00000 -o test/Memory/pdf.out.reloc test/Memory/pdf.out
	@riscv64-unknown-elf-objcopy -O binary -j .text test/Memory/pdf.out.reloc test/Memory/pdf.bin
	@riscv64-unknown-elf-objdump -D -S -l -F -Mno-aliases test/Memory/pdf.out.reloc > test/Assembly/pdf.asm
	@od -v -An -t x1 test/Memory/pdf.bin | tr -s '\n' | awk '{pdf=pdf};1' > test/Memory/pdf.mem
	@rm test/Memory/pdf.out
	@rm test/Memory/pdf.out.reloc
	@rm test/Memory/pdf.bin

F1Lights: test/Assembly/F1Lights.s
	@riscv64-unknown-elf-as -R -march=rv32im -mabi=ilp32 -o test/Memory/F1Lights.out test/Assembly/F1Lights.s
	@riscv64-unknown-elf-ld -melf32lriscv -e 0xBFC00000 -Ttext 0xBFC00000 -o test/Memory/F1Lights.out.reloc test/Memory/F1Lights.out
	@riscv64-unknown-elf-objcopy -O binary -j .text test/Memory/F1Lights.out.reloc test/Memory/F1Lights.bin
	@riscv64-unknown-elf-objdump -D -S -l -F -Mno-aliases test/Memory/F1Lights.out.reloc > test/Assembly/F1Lights.asm
	@od -v -An -t x1 test/Memory/F1Lights.bin | tr -s '\n' | awk '{F1Lights=F1Lights};1' > test/Memory/F1Lights.mem
	@rm test/Memory/F1Lights.out
	@rm test/Memory/F1Lights.out.reloc
	@rm test/Memory/F1Lights.bin

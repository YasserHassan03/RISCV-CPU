
test/Memory/pdfPipelined.out.reloc:     file format elf32-littleriscv


Disassembly of section .text:

bfc00000 <main> (File Offset: 0x1000):
main():
bfc00000:	030000ef          	jal	ra,bfc00030 <init> (File Offset: 0x1030)
bfc00004:	00000013          	addi	zero,zero,0
bfc00008:	00000013          	addi	zero,zero,0
bfc0000c:	058000ef          	jal	ra,bfc00064 <build> (File Offset: 0x1064)
bfc00010:	00000013          	addi	zero,zero,0
bfc00014:	00000013          	addi	zero,zero,0

bfc00018 <forever> (File Offset: 0x1018):
forever():
bfc00018:	0c0000ef          	jal	ra,bfc000d8 <display> (File Offset: 0x10d8)
bfc0001c:	00000013          	addi	zero,zero,0
bfc00020:	00000013          	addi	zero,zero,0
bfc00024:	ff5ff06f          	jal	zero,bfc00018 <forever> (File Offset: 0x1018)
bfc00028:	00000013          	addi	zero,zero,0
bfc0002c:	00000013          	addi	zero,zero,0

bfc00030 <init> (File Offset: 0x1030):
init():
bfc00030:	0ff00593          	addi	a1,zero,255
bfc00034:	00000013          	addi	zero,zero,0
bfc00038:	00000013          	addi	zero,zero,0

bfc0003c <_loop1> (File Offset: 0x103c):
_loop1():
bfc0003c:	10058023          	sb	zero,256(a1)
bfc00040:	fff58593          	addi	a1,a1,-1
bfc00044:	00000013          	addi	zero,zero,0
bfc00048:	00000013          	addi	zero,zero,0
bfc0004c:	fe0598e3          	bne	a1,zero,bfc0003c <_loop1> (File Offset: 0x103c)
bfc00050:	00000013          	addi	zero,zero,0
bfc00054:	00000013          	addi	zero,zero,0
bfc00058:	00008067          	jalr	zero,0(ra)
bfc0005c:	00000013          	addi	zero,zero,0
bfc00060:	00000013          	addi	zero,zero,0

bfc00064 <build> (File Offset: 0x1064):
build():
bfc00064:	000105b7          	lui	a1,0x10
bfc00068:	00000613          	addi	a2,zero,0
bfc0006c:	10000693          	addi	a3,zero,256
bfc00070:	0c800713          	addi	a4,zero,200

bfc00074 <_loop2> (File Offset: 0x1074):
_loop2():
bfc00074:	00c587b3          	add	a5,a1,a2
bfc00078:	00000013          	addi	zero,zero,0
bfc0007c:	00000013          	addi	zero,zero,0
bfc00080:	0007c283          	lbu	t0,0(a5)
bfc00084:	00000013          	addi	zero,zero,0
bfc00088:	00000013          	addi	zero,zero,0
bfc0008c:	00d28833          	add	a6,t0,a3
bfc00090:	00000013          	addi	zero,zero,0
bfc00094:	00000013          	addi	zero,zero,0
bfc00098:	00084303          	lbu	t1,0(a6)
bfc0009c:	00000013          	addi	zero,zero,0
bfc000a0:	00000013          	addi	zero,zero,0
bfc000a4:	00130313          	addi	t1,t1,1
bfc000a8:	00000013          	addi	zero,zero,0
bfc000ac:	00000013          	addi	zero,zero,0
bfc000b0:	00680023          	sb	t1,0(a6)
bfc000b4:	00000013          	addi	zero,zero,0
bfc000b8:	00000013          	addi	zero,zero,0
bfc000bc:	00160613          	addi	a2,a2,1
bfc000c0:	fae31ae3          	bne	t1,a4,bfc00074 <_loop2> (File Offset: 0x1074)
bfc000c4:	00000013          	addi	zero,zero,0
bfc000c8:	00000013          	addi	zero,zero,0
bfc000cc:	00008067          	jalr	zero,0(ra)
bfc000d0:	00000013          	addi	zero,zero,0
bfc000d4:	00000013          	addi	zero,zero,0

bfc000d8 <display> (File Offset: 0x10d8):
display():
bfc000d8:	00000593          	addi	a1,zero,0
bfc000dc:	0ff00613          	addi	a2,zero,255

bfc000e0 <_loop3> (File Offset: 0x10e0):
_loop3():
bfc000e0:	00000013          	addi	zero,zero,0
bfc000e4:	1005c503          	lbu	a0,256(a1) # 10100 <base_data+0x100> (File Offset: 0xffffffff40411100)
bfc000e8:	00158593          	addi	a1,a1,1
bfc000ec:	00000013          	addi	zero,zero,0
bfc000f0:	00000013          	addi	zero,zero,0
bfc000f4:	fec596e3          	bne	a1,a2,bfc000e0 <_loop3> (File Offset: 0x10e0)
bfc000f8:	00000013          	addi	zero,zero,0
bfc000fc:	00000013          	addi	zero,zero,0
bfc00100:	00008067          	jalr	zero,0(ra)
bfc00104:	00000013          	addi	zero,zero,0
bfc00108:	00000013          	addi	zero,zero,0

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes> (File Offset: 0x110c):
   0:	1e41                	.2byte	0x1e41
   2:	0000                	.2byte	0x0
   4:	7200                	.2byte	0x7200
   6:	7369                	.2byte	0x7369
   8:	01007663          	bgeu	zero,a6,14 <max_count-0xb4> (File Offset: 0x1120)
   c:	0014                	.2byte	0x14
   e:	0000                	.2byte	0x0
  10:	7205                	.2byte	0x7205
  12:	3376                	.2byte	0x3376
  14:	6932                	.2byte	0x6932
  16:	7032                	.2byte	0x7032
  18:	5f30                	.2byte	0x5f30
  1a:	326d                	.2byte	0x326d
  1c:	3070                	.2byte	0x3070
	...


test/Memory/F1LightsPipelined.out.reloc:     file format elf32-littleriscv


Disassembly of section .text:

bfc00000 <default> (File Offset: 0x1000):
default():
bfc00000:	00100493          	addi	s1,zero,1
bfc00004:	0ff00913          	addi	s2,zero,255
bfc00008:	00c00993          	addi	s3,zero,12
bfc0000c:	00100693          	addi	a3,zero,1

bfc00010 <reset> (File Offset: 0x1010):
reset():
bfc00010:	00000513          	addi	a0,zero,0
bfc00014:	00000713          	addi	a4,zero,0
bfc00018:	00000293          	addi	t0,zero,0
bfc0001c:	00000013          	addi	zero,zero,0
bfc00020:	00000013          	addi	zero,zero,0

bfc00024 <mloop> (File Offset: 0x1024):
mloop():
bfc00024:	04928863          	beq	t0,s1,bfc00074 <fsm> (File Offset: 0x1074)
bfc00028:	00000013          	addi	zero,zero,0
bfc0002c:	00000013          	addi	zero,zero,0
bfc00030:	0036d613          	srli	a2,a3,0x3
bfc00034:	00000013          	addi	zero,zero,0
bfc00038:	00000013          	addi	zero,zero,0
bfc0003c:	00d64633          	xor	a2,a2,a3
bfc00040:	00000013          	addi	zero,zero,0
bfc00044:	00000013          	addi	zero,zero,0
bfc00048:	00167613          	andi	a2,a2,1
bfc0004c:	00169693          	slli	a3,a3,0x1
bfc00050:	00000013          	addi	zero,zero,0
bfc00054:	00000013          	addi	zero,zero,0
bfc00058:	00c686b3          	add	a3,a3,a2
bfc0005c:	00000013          	addi	zero,zero,0
bfc00060:	00000013          	addi	zero,zero,0
bfc00064:	00f6f693          	andi	a3,a3,15
bfc00068:	fbdff0ef          	jal	ra,bfc00024 <mloop> (File Offset: 0x1024)
bfc0006c:	00000013          	addi	zero,zero,0
bfc00070:	00000013          	addi	zero,zero,0

bfc00074 <fsm> (File Offset: 0x1074):
fsm():
bfc00074:	058000ef          	jal	ra,bfc000cc <count> (File Offset: 0x10cc)
bfc00078:	00000013          	addi	zero,zero,0
bfc0007c:	00000013          	addi	zero,zero,0
bfc00080:	00151313          	slli	t1,a0,0x1
bfc00084:	00000013          	addi	zero,zero,0
bfc00088:	00000013          	addi	zero,zero,0
bfc0008c:	00130513          	addi	a0,t1,1
bfc00090:	00000013          	addi	zero,zero,0
bfc00094:	00000013          	addi	zero,zero,0
bfc00098:	fd251ee3          	bne	a0,s2,bfc00074 <fsm> (File Offset: 0x1074)
bfc0009c:	00000013          	addi	zero,zero,0
bfc000a0:	00000013          	addi	zero,zero,0

bfc000a4 <delay> (File Offset: 0x10a4):
delay():
bfc000a4:	f6d706e3          	beq	a4,a3,bfc00010 <reset> (File Offset: 0x1010)
bfc000a8:	00000013          	addi	zero,zero,0
bfc000ac:	00000013          	addi	zero,zero,0
bfc000b0:	01c000ef          	jal	ra,bfc000cc <count> (File Offset: 0x10cc)
bfc000b4:	00000013          	addi	zero,zero,0
bfc000b8:	00000013          	addi	zero,zero,0
bfc000bc:	00170713          	addi	a4,a4,1
bfc000c0:	fe5ff0ef          	jal	ra,bfc000a4 <delay> (File Offset: 0x10a4)
bfc000c4:	00000013          	addi	zero,zero,0
bfc000c8:	00000013          	addi	zero,zero,0

bfc000cc <count> (File Offset: 0x10cc):
count():
bfc000cc:	00158593          	addi	a1,a1,1
bfc000d0:	00000013          	addi	zero,zero,0
bfc000d4:	00000013          	addi	zero,zero,0
bfc000d8:	ff359ae3          	bne	a1,s3,bfc000cc <count> (File Offset: 0x10cc)
bfc000dc:	00000013          	addi	zero,zero,0
bfc000e0:	00000013          	addi	zero,zero,0
bfc000e4:	00000593          	addi	a1,zero,0
bfc000e8:	000080e7          	jalr	ra,0(ra)
bfc000ec:	00000013          	addi	zero,zero,0
bfc000f0:	00000013          	addi	zero,zero,0

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes> (File Offset: 0x10f4):
   0:	1e41                	.2byte	0x1e41
   2:	0000                	.2byte	0x0
   4:	7200                	.2byte	0x7200
   6:	7369                	.2byte	0x7369
   8:	01007663          	bgeu	zero,a6,14 <default-0xbfbfffec> (File Offset: 0x1108)
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

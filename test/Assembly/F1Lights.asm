
test/Memory/F1Lights.out.reloc:     file format elf32-littleriscv


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

bfc0001c <mloop> (File Offset: 0x101c):
mloop():
bfc0001c:	02928063          	beq	t0,s1,bfc0003c <fsm> (File Offset: 0x103c)
bfc00020:	0036d613          	srli	a2,a3,0x3
bfc00024:	00d64633          	xor	a2,a2,a3
bfc00028:	00167613          	andi	a2,a2,1
bfc0002c:	00169693          	slli	a3,a3,0x1
bfc00030:	00c686b3          	add	a3,a3,a2
bfc00034:	00f6f693          	andi	a3,a3,15
bfc00038:	fe5ff0ef          	jal	ra,bfc0001c <mloop> (File Offset: 0x101c)

bfc0003c <fsm> (File Offset: 0x103c):
fsm():
bfc0003c:	020000ef          	jal	ra,bfc0005c <count> (File Offset: 0x105c)
bfc00040:	00151313          	slli	t1,a0,0x1
bfc00044:	00130513          	addi	a0,t1,1
bfc00048:	ff251ae3          	bne	a0,s2,bfc0003c <fsm> (File Offset: 0x103c)

bfc0004c <delay> (File Offset: 0x104c):
delay():
bfc0004c:	fcd702e3          	beq	a4,a3,bfc00010 <reset> (File Offset: 0x1010)
bfc00050:	00c000ef          	jal	ra,bfc0005c <count> (File Offset: 0x105c)
bfc00054:	00170713          	addi	a4,a4,1
bfc00058:	ff5ff0ef          	jal	ra,bfc0004c <delay> (File Offset: 0x104c)

bfc0005c <count> (File Offset: 0x105c):
count():
bfc0005c:	00158593          	addi	a1,a1,1
bfc00060:	ff359ee3          	bne	a1,s3,bfc0005c <count> (File Offset: 0x105c)
bfc00064:	00000593          	addi	a1,zero,0
bfc00068:	000080e7          	jalr	ra,0(ra)

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes> (File Offset: 0x106c):
   0:	1e41                	.2byte	0x1e41
   2:	0000                	.2byte	0x0
   4:	7200                	.2byte	0x7200
   6:	7369                	.2byte	0x7369
   8:	01007663          	bgeu	zero,a6,14 <default-0xbfbfffec> (File Offset: 0x1080)
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

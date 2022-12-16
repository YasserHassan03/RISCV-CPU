/* 
ra - return address
t0 - trigger
t1 - temp for a0
s1 - const 1
s2 - const 255
s3 - const 5 (adjust for count)
a1 - counter var
a2 - xor bit var
a3 - pseudo random var
a4 - delay counter var
*/

default:
    addi s1, zero, 0x1  
    addi s2, zero, 0xff 
    addi s3, zero, 0x3  /* MAY MAKE BIGGER */
    addi a3, zero, 0x1 

reset:
    addi a0, zero, 0x0  /* reset output */
    addi a4, zero, 0x0  /* reset delay counter */
    addi t0, zero, 0x0  /* reset trigger */
    nop
    nop

mloop:
    beq  t0, s1, fsm    /* check trigger */ 
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop
    srli a2, a3, 0x3    /* send 4th bit to 1st bit */
    nop                 /* one cycle delay to get result through memory section*/
    nop                 /* one cycle delay to write result on negative edge*/
    xor  a2, a2, a3     /* xor 4th bit and 1st bit */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    andi a2, a2, 0x1    /* remove other bits */
    slli a3, a3, 0x1    /* shift number left by 1 */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    add  a3, a3, a2     /* add xor and shifted bits */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    andi a3, a3, 0xf    /* remove additional bits */
    jal  ra, mloop      /* Loop  */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop

fsm:
    jal  ra, count      /* add const delay */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop
    slli t1, a0, 0x1    /* shift temp output bits left by 1 */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    addi a0, t1, 0x1    /* add 1 to shifted bits for output */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /*one cycle delay to write result on negative edge*/
    bne  a0, s2, fsm    /* if not all lights are on Loop */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop
    
delay:
    beq  a4, a3, reset  /* if delay counter is finished reset */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop
    jal  ra, count      /* jump to counter MAY NOT NEED THIS */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop
    addi a4, a4, 0x1    /* increment delay counter */
    jal  ra, delay      /* Loop */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop

count: 
    addi  a1, a1, 0x1   /* counter++ */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    bne   a1, s3, count /* Loop if counting */
    nop                 /* one cycle delay to get result through memory*/
    nop                 /* one cycle delay to write result on negative edge*/
    addi  a1, zero, 0x0 /* reset counter */
    jalr  ra, ra, 0x0   /* return to fsm */
    nop                 /* two cycles delay to let jump get to PCsrc logic*/ 
    nop

# iac-riscv-cw-32
## f1 machine code

One of the ways we tested the cpu works, was through writing an assembly language code to implement the F1 starting light algorithm from lab 3. The diagram for the state machine we were supposed to be implementing can be seen below (image taken from lab 3):

<img width="818" alt="Screenshot 2022-12-08 at 09 12 52" src="https://user-images.githubusercontent.com/116260803/206406136-199757c4-16d2-4f60-b2b5-da45afca4444.png">

Aside from executing the statemachine, we had to implement two different types of delay to ensure our program was as similar as possible to Lab 3. We implemented a constant delay between each red light and the next as well as a pseudo-random delay before all the random lights turn off and reset.
### Assembly Code Overview

The lfsr used in the random delay implementation is constantly running in the background (more on this in the random delay section). As soon as trigger is asserted manually (by pressing the 't' button or the rotary switch on the vbuddy) the lfsr stops (calculating the 'random' number) and the rest of the assembly code starts. We store the value of the statemachine in the register a0. In the first cycle after trigger is asserted, we perform a left shift on a0 and store it in a temporary register then add one and put it back in the original register a0. The reason we use the temporary register is because if we shift and store in a0 then later add to a0 we would have a temporary step where we have only shifted and not added that would be displayed, thus ruining our light display. We then implement a small constant delay (more on this below) between each red light and then jump back to the fsm and repeat as long as the value in a0 is not equal to s2, which is a register we have set to a constant value of 255 or 0xff, the value of state 8. Once the value is equal to 0xff and we are in state 8, we then implement the random delay and proceed to reset. 

### Constant delay between red lights

While testing, we thought that the lights were cycling through too quickly, not giving us a chance to properly see if our implementation was correct so we implemented a constant delay to allow us to see the light cycling better. To do this, we set a register s3 equal to a constant we decided on through trial and error. We then counted up from 0 in a register a1. We continued to count untill the value in a1 was equal to the value in s3 before then resetting a1 and jumping back to the fsm subroutine.

``` assembly
count:
    addi  a1, a1, 0x1   ; counter++ 
    bne   a1, s3, count ; Loop if counting 
    addi  a1, zero, 0x0 ; reset counter 
    jalr  ra, ra, 0x0   ; return to fsm 
 ```

### Random delay implementation

We wanted to make our program as close as possible to the real F1 lights simulation. To do this, we needed to implement a random delay, however we knew that there was no way to get truly random results, so instead we implemented a pseudo-random delay through an lfsr. In the main, constantly running, we have 1 stored in register a3. We then perform a right shift by 3 bits, and store the value of a3 in a2. This basically puts the fourth bit of a3 (most significant bit) into the first bit of a2, allowing us to xor the first and fourth bit, by xoring the registers (store result in a2). We then and a2 with 0001, to turn the first three bits of a2 in to zeroes while maintaining the fourth bit. This is the only one we care about as we are xoring the first and fourth bit. We then shift a3 left by 1-bit , add a2 to a3 after the shift, and store in a3. The primitive polynomial for this lfsr is given by  $1$ + $X$ + $X^4$.
The lfsr runs untill the trigger is manually asserted('t' is pressed or the rotary switch is pressed on the vbuddy) at which point the current value is decided on as the random number. The delay is then implemented as the random number, multiplied by the constant delay time between the red lights, it does this by performing the constant delay described above n times where n is the random number calculated by the lfsr.

``` assembly
mloop:
    beq  t0, s1, fsm    ; check trigger  
    ; lfsr starts 
    srli a2, a3, 0x3    ; send 4th bit to 1st bit 
    xor  a2, a2, a3     ; xor 4th bit and 1st bit 
    andi a2, a2, 0x1    ; remove other bits 
    slli a3, a3, 0x1    ; shift number left by 1 
    add  a3, a3, a2     ; add xor and shifted bits 
    andi a3, a3, 0xf    ; remove additional bits 
    ; lfsr ends 
    jal  ra, mloop      ; Loop  
    
delay:
    beq  a4, a3, reset  ; if delay counter is finished reset 
    jal  ra, count      ; jump to counter 
    addi a4, a4, 0x1    ; increment delay counter 
    jal  ra, delay      ; Loop 
    
```


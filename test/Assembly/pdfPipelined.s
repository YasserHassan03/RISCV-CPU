.text
.equ base_pdf, 0x100
.equ base_data, 0x10000
.equ max_count, 200

main:
    jal     ra, init  # jump to init, ra and save position to ra
    nop               #two cycle delay to allow jump to get to PCsrc logic
    nop
    jal     ra, build
    nop              #two cycle delay to allow jump to get to PCsrc logic    
    nop
forever:
    jal     ra, display
    nop                #two cycle delay to allow jump to get to PCsrc logic
    nop
    j       forever
    nop                 #two cycle delay to allow jump to get to PCsrc logic
    nop

init:       # function to initialise pdf buffer memory 
    li      a1, 0xff            # loop_count a1 = 255
    nop
    nop
_loop1:                         # repeat
    sb      zero, base_pdf(a1)  #     mem[base_pdf+a1) = 0
    addi    a1, a1, -1          #     decrement a1
    nop
    nop
    bne     a1, zero, _loop1    # until a1 = 0
    nop
    nop
    ret
    nop
    nop

build:      # function to build prob dist func (pdf)
    li      a1, base_data       # a1 = base address of data array
    li      a2, 0               # a2 = offset into of data array 
    li      a3, base_pdf        # a3 = base address of pdf array
    li      a4, max_count       # a4 = maximum count to terminate
_loop2:                         # repeat
    add     a5, a1, a2          #     a5 = data base address + offset
    nop
    nop
    lbu     t0, 0(a5)           #     t0 = data value
    nop
    nop
    add     a6, t0, a3          #     a6 = index into pdf array
    nop
    nop
    lbu     t1, 0(a6)           #     t1 = current bin count
    nop
    nop
    addi    t1, t1, 1           #     increment bin count
    nop
    nop
    sb      t1, 0(a6)           #     update bin count
    nop
    nop
    addi    a2, a2, 1           #     point to next data in array
    bne     t1, a4, _loop2      # until bin count reaches max
    nop
    nop 
    ret
    nop
    nop

display:    # function send pdf array value to a0 for display
    li      a1, 0               # a1 = offset into pdf array
    li      a2, 255             # a2 = max index of pdf array
_loop3:                         # repeat
    nop
    lbu     a0, base_pdf(a1)    #   a0 = mem[base_pdf+a1)
    addi    a1, a1, 1           #   incr 
    nop
    nop
    bne     a1, a2, _loop3      # until end of pdf array
    nop
    nop
    ret
    nop
    nop


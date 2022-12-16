.text
.equ base_pdf, 0x100
.equ base_data, 0x10000
.equ max_count, 200

main:
    jal     ra, init  # jump to init, ra and save position to ra
    jal     ra, build
forever:
    jal     ra, display
    j       forever

init:       # function to initialise pdf buffer memory 
    li      a1, 0xff            # loop_count a1 = 255
_loop1:                         # repeat
    sb      zero, base_pdf(a1)  #     mem[base_pdf+a1) = 0
    addi    a1, a1, -1          #     decrement a1
    bne     a1, zero, _loop1    # until a1 = 0
    ret

build:      # function to build prob dist func (pdf)
    li      a1, base_data       # a1 = base address of data array
    li      a2, 0               # a2 = offset into of data array 
    li      a3, base_pdf        # a3 = base address of pdf array
    li      a4, max_count       # a4 = maximum count to terminate
_loop2:                         # repeat
    add     a5, a1, a2          #     a5 = data base address + offset
    lbu     t0, 0(a5)           #     t0 = data value
    add     a6, t0, a3          #     a6 = index into pdf array
    lbu     t1, 0(a6)           #     t1 = current bin count
    addi    t1, t1, 1           #     increment bin count
    sb      t1, 0(a6)           #     update bin count
    addi    a2, a2, 1           #     point to next data in array
    bne     t1, a4, _loop2      # until bin count reaches max
    ret

display:    # function send pdf array value to a0 for display
    li      a1, 0               # a1 = offset into pdf array
    li      a2, 255             # a2 = max index of pdf array
_loop3:                         # repeat
    lbu     a0, base_pdf(a1)    #   a0 = mem[base_pdf+a1)
    addi    a1, a1, 1           #   incr 
    bne     a1, a2, _loop3      # until end of pdf array
    ret

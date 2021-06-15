//Counter_loop (Count/Increment 1 till 10)

#include "defines.h"

#define STDOUT 0xd0580000


    
 // Code to execute
.section .text
.global _start
_start:

    // Clear minstret
    csrw minstret, zero
    csrw minstreth, zero
    li x1, 0x5f555555
    csrw 0x7c0, x1
    li x1, 4
    csrw 0x7f9, x1

    li x8, 0xf0040000 // dccm address
    li x3, STDOUT	    
    addi x9, x0, 0xA  //no of values needs to be count 
    addi x6, x0, 0    
    addi x12, x0, 0   //initial value to start loop 
    addi x11, x0, 0   //increment value from x12 save in x11 register
    addi x13, x0, 0
 
    
store:    
    add x5, x0, x6 
    sw x5, 0(x8)
    addi x6, x6, 1
    addi x8, x8, 4
    bne x9, x6, store
    li x8, 0xf0040000
    j counter_loop
    
next:
    sw x11, 0(x8) 
    addi x8, x8, 4
    sw x11, 0(x3)
    addi x3, x3, 4
    beq x13, x9, _finish
    addi x13, x13, 1
    addi x11, x0, 1
    addi x12, x0, 1
    
counter_loop:
    
    addi x11, x12, 1
    beq x12, x13,  next
    addi x12, x12, 1
    j counter_loop
    
    
    

    
	
// Write 0xff to STDOUT for TB to termiate test.
_finish:
    li x3, STDOUT
    addi x5, x0, 0xff
    sb x5, 0(x3)
    beq x0, x0, _finish
.rept 100
    nop
.endr


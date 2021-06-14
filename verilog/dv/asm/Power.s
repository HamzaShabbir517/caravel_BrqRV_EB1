#include "defines.h"

#define STDOUT 0xd0580000


// Code to execute
.section .text
.global _start
_start:

csrw minstret, zero
csrw minstreth, zero
li x1, 0x5f555555
csrw 0x7c0, x1
li x1, 4
csrw 0x7f9, x1
nop

li x8,0xf0040000	//For Load
li x19,STDOUT		//B.addr

li x5,4  // Base number
sb x5,0(x8)
//li x5,4  // Base number
//sb x5,4(x8)
li x5,3	 // power number
sb x5,4(x8)
lb x5,0(x8)
lb x6,0(x8)
lb x7,4(x8)
addi x7,x7,-1
loop:
mul x6,x6,x5
addi x7,x7,-1
beq x7,x0,exit
bne x7,x0,loop
exit:
sb x6,0(x19)


// Write 0xff to STDOUT for TB to termiate test.
_finish:
    li x3, STDOUT
    addi x5, x0, 0xff
    sb x5, 0(x3)
    beq x0, x0, _finish
.rept 100
    nop
.endr


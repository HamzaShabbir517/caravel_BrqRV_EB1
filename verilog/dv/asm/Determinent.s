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

li	x5,4		//A1 of matrix
sb	x5,0(x8)
li 	x5,3		//A2 of matrix
sb	x5,1(x8)
li	x5,1		//A3 of matrix
sb	x5,2(x8)
li	x5,2		//A4 of matrix
sb	x5,3(x8)

//Determinent
lb	x5,0(x8)		
lb	x6,3(x8)
mul	x7,x5,x6		//Multiply diagonal A1 and A4
lb	x5,1(x8)
lb	x6,2(x8)
mul	x8,x5,x6		//Multiply diagonal A2 and A3
sub	x5,x7,x8		//Determinent result
sb	x5,5(x8)		//Save to DCCM
sb	x5,0(x19)		//Save to AXI

// Write 0xff to STDOUT for TB to termiate test.
_finish:
    li x3, STDOUT
    addi x5, x0, 0xff
    sb x5, 0(x3)
    beq x0, x0, _finish
.rept 100
    nop
.endr


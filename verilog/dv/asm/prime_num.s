// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

#include "defines.h"

#define STDOUT 0xd0580000

// Code to execute
.section .text
.global _start
_start:

//Prime numbers in a given range 

// li x1, 0x5f555555
// csrw 0x7c0, x1

csrw minstret, zero
csrw minstreth, zero
 
li x4, 4        // Neccessary for terminating code
csrw 0x7f9 ,x4  // Neccessary for terminating code
nop

li s0,0 // count of divisors
li s1,1 // minimun range INPUT    Expected result = 1 3 5 7 11 13
li s2,15 // maximum range INPUT
li t1,1 // divider
li t2,2 
li t5,1
li t3,0xf0040000 //base adress
li t4,STDOUT

beq s1,t5,STORE
LOOP2:
addi s1,s1,2
li t5,0

LOOP:
beq s1,s2,END
rem t0,s1,t1
beqz t0,INC
addi t1,t1,1
beq t1,s1,LOOP1
j LOOP

INC:
addi s0,s0,1
addi t1,t1,1
beq t1,s1,LOOP1
j LOOP

LOOP1:
addi s0,s0,1
beq s0,t2,STORE
li t1,1
li s0,0
addi s1,s1,1
j LOOP

STORE:
sw s1,0(t3)
sw s1,0(t4)
addi t3,t3,4
addi t4,t4,4
beq s1,t5,LOOP2
bne s1,s2,LOOP1
END:



// Write 0xff to STDOUT for TB to termiate test.
_finish:
    li x3, STDOUT
    addi x5, x0, 0xff
    sb x5, 0(x3)
    beq x0, x0, _finish
.rept 100
    nop
.endr

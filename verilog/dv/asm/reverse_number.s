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

li s0,15 // UPPER BOUND
li t0,0 // COUNTER
li t1,0xf0040000 // BASE ADRESS
li t3,1
addi t0,s0,0
li t2,STDOUT

LOOP:

sw t0,0(t1)
sw t0,0(t2)
addi t2,t2,4
addi t1,t1,4
beqz t0,END
sub t0,t0,t3

j LOOP

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

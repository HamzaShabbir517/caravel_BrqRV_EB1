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
    
    csrw minstret, zero
    csrw minstreth, zero
    li x1, 0x5f555555
    csrw 0x7c0, x1
    li x1, 4
    csrw 0x7f9, x1
nop
li x8,0xf0040000	//For Load
li x19,STDOUT		//B.addr

li x5,4				//Value1
sb x5,0(x8)			//Stored in loc 1
li x5,5				//Value2
sb x5,1(x8)			//Stored in loc 2
li x5,6				//Value3
sb x5,2(x8)			//Stored in loc 3
lb x5,0(x8)			//Load 1st Value
lb x6,1(x8)			//Load 2nd Value
add x7,x5,x6		//Adding First two values
lb x5,2(x8)			//Load 3rd Value
add x6,x7,x5		//Sum of all three values
li x5,3				//divisor value (total number of values)
div x7,x6,x5		//MEAN
sb x7,3(x8)         //Store to DCCM
sb x7,0(x19)		//Store to AXI

// Write 0xff to STDOUT for TB to termiate test.
_finish:
    li x3, STDOUT
    addi x5, x0, 0xff
    sb x5, 0(x3)
    beq x0, x0, _finish
.rept 100
    nop
.endr

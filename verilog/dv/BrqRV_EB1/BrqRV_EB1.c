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

#include "verilog/dv/caravel/defs.h"
#include "verilog/dv/caravel/stub.c"

void main()
{

        /* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

	reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.


   //reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_NOPULL;
   //reg_mprj_io_1 = GPIO_MODE_USER_STD_INPUT_NOPULL;
   //reg_mprj_io_2 = GPIO_MODE_USER_STD_INPUT_NOPULL;
   reg_mprj_io_3 = GPIO_MODE_USER_STD_INPUT_NOPULL;
   //reg_mprj_io_4 = GPIO_MODE_USER_STD_OUTPUT;
   reg_mprj_io_5 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  // reg_mprj_io_6 = GPIO_MODE_USER_STD_OUTPUT;
  // reg_mprj_io_7 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_8 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_9 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_10 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_11 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_12 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_13 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_14 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_15 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_16 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_17 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_18 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_19 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_20 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_21 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_22 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_23 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_24 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_25 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_26 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_28 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_30 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_31 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_32 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_33 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_34 = GPIO_MODE_USER_STD_OUTPUT;
  reg_mprj_io_35 = GPIO_MODE_USER_STD_INPUT_NOPULL;
  
  reg_mprj_io_37 = GPIO_MODE_MGMT_STD_OUTPUT;

  reg_mprj_xfer = 1;
  while(reg_mprj_xfer == 1);
   
  // For CPU input keep bit 1 for output from CPU keep bit 0 
  reg_la0_oenb = reg_la0_iena = 0x00000000;    // [31:0] 
  reg_la1_oenb = reg_la1_iena = 0xFFFF0000;    // [63:32]
  reg_la2_oenb = reg_la2_iena = 0xFFFFFFFE;    // [95:64]
  reg_la3_oenb = reg_la3_iena = 0xFFFFFFFF;    // [127:96]
  
  // Set clk & reset to one
  reg_la2_data = 0x00000001;
  reg_la2_data = 0x00000000;
  
  // writing data into memory 1
  reg_la0_data = 0x00000002; // 0
  reg_la0_data = 0x0008000a; // 1 
  reg_la0_data = 0x00100012; // 2
  reg_la0_data = 0x0018001a; // 3 
  reg_la0_data = 0x00200022; // 4
  reg_la0_data = 0x0028002a; // 5 
  reg_la0_data = 0x00300032; // 6
  reg_la0_data = 0x0038003a; // 7
  reg_la0_data = 0x00400042; // 8
  reg_la0_data = 0x0048004a; // 9     
  
  // Turning off memory 1
  reg_la0_data = 0x00000007;  
  
  // writing data into memory 2
  reg_la0_data = 0x00000001; // 0
  reg_la0_data = 0x00080009; // 1 
  reg_la0_data = 0x00100011; // 2
  reg_la0_data = 0x00180019; // 3 
  reg_la0_data = 0x00200021; // 4
  reg_la0_data = 0x00280029; // 5 
  reg_la0_data = 0x00300031; // 6
  reg_la0_data = 0x00380039; // 7
  reg_la0_data = 0x00400041; // 8
  reg_la0_data = 0x00480049; // 9     
  
  // Turning off memory 2
  reg_la0_data = 0x00000007;  
  reg_la0_oenb = reg_la0_iena = 0xFFFFFFFF;    // [31:0] 
  reg_la1_oenb = reg_la1_iena = 0xFFFFFFFF;    // [63:32]
  reg_la2_oenb = reg_la2_iena = 0xFFFFFFFF;    // [95:64]
  reg_la3_oenb = reg_la3_iena = 0xFFFFFFFF;    // [127:96]

  reg_mprj_datah = 0x20;

}

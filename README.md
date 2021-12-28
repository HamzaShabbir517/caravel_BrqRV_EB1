[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

SPDX-FileCopyrightText: 2020 Efabless Corporation
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
SPDX-License-Identifier: Apache-2.0

# RAM Generator from MERL

This repository contains the memories generated by our RAM Generator using sky130 sram as a base model for testing purpose.



## Directory Structure

    ├── verlog                          #   User verilog Directory
    │   ├── rtl                         #   RTL
    │   ├── dv                          #   Design Verification
    │   ├── gl                          #   Gate Level Netlis
    
   #  The Memories Source Code is avaialable here
    
    ├── verlog                               #   User verilog Directory
    │   ├── rtl                              #   RTL
    |       ├── user_project_wrapper.v       #   User Project Wrapper source file
    |       ├── user_proj_example.v          #   User Project Example source file
    |       ├── rams                         #   Rams folder
    |           ├── ram_256x32_2r1w          #   Ram 256x32 2r1w folder
    |               ├── ram_generated_256x32_2r1w.v             #   RAM 2r1w source file
    |               ├── ram_generated_256x32_1rw.v              #   RAM 1rw source file
    |               ├── sky130_sram_1kbyte_1rw1r_32x256_8.v     #   1KB sram
    |               ├── utils.vh     				 #   utils header file
    
    
   # The Design Verification Testbench is available here 
    ├── verlog                               #   User verilog Directory
    │   ├── dv                               #   Design Verification
    │       ├── BrqRV_EB1                    #   Design Test Directory
    │       ├── hex                          #   Hex files folder
    │       ├── asm                          #   Assmebly files folder
     
  # The synthesized netlist is present here:
  
    ├── verlog                               #   User verilog Directory
    │   ├── gl                               #   Gate Level Netlis
    │       ├── user_project_wrapper.v       #   User Project Wrapper Netlist
    │       ├── user_proj_example.v          #   User Project Example Netlist
    
 # The hardened macros are placed here:

    ├── def                                 #    def Directory
    │   ├── user_project_wrapper.def        #    User Project Wrapper def file
    
    ├── lef                                 #    lef Directory
    │   ├── user_project_wrapper.lef        #    User Project Wrapper lef file
    │   ├── user_proj_example.lef           #    User Project Example lef file
    
    ├── gds                                 #    gds Directory
    │   ├── user_project_wrapper.gdz.gz     #    User Project Wrapper gds
    │   ├── user_proj_example.gdz.gz        #    User Project Example gds


### Testing of Design

Go to verilog/dv/BrqRV_EB1/ directory

1. Set the GCC_PATH environment variable.
2. Set the PDK_PATH environment variable.
4. run the make commad for RTL simulation
5. run the SIM=GL make command for netlist simulation



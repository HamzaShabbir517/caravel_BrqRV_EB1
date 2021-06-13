# BrqRV EB1 RISC-V Core 1.0 from MERL

This repository contains the brqrv eb1 Core design RTL. Brqrv Eb1 Is A Machine-Mode (M-Mode) Only, 32-Bit Cpu Small Core Which Supports Risc-V’s Integer (I), Compressed Instruction (C), Multiplication And Division (M), And Instruction-Fetch Fence, And Csr Extensions. The Core Contains A 4-Stage, Scalar, In-Order Pipeline

## Block Diagram
![](docs/BrqRV_EB1.png)

## Directory Structure

    ├── verlog                          #   User verilog Directory
    │   ├── rtl                         #   RTL
    │   ├── dv                          #   Design Verification
    │   ├── gl                          #   Gate Level Netlis
    
   #  The BrqRV_EB1 Source Code is avaialable here
    
    ├── verlog                               #   User verilog Directory
    │   ├── rtl                              #   RTL
    |       ├── Brqrv_EB1                    #   BrqRV_EB1 folder
    |           ├── Brqrv_EB1.v                                     #   BrqRV_EB1 source file
    |           ├── sky130_sram_1kbyte_1rw1r_32x256_8.v             #   1KB sram
    
    
   # The Design Verification Testbench is available here 
    ├── verlog                               #   User verilog Directory
    │   ├── dv                               #   Design Verification
    │       ├── BrqRV_EB1                    #   Design Test Directory
    │       ├── hex                          #   Hex file folder
     
  # The synthesized netlist is present here:
  
    ├── verlog                               #   User verilog Directory
    │   ├── gl                               #   Gate Level Netlis
    │       ├── BrqRV_EB1                    #   User Design Netlist
    
 # The hardened macros are placed here:

    ├── def                                 #    def Directory
    │   ├── BrqRV_EB1                       #    User Design def
    
    ├── lef                                 #    lef Directory
    │   ├── BrqRV_EB1                       #    User Design lef
    
    ├── gds                                 #    gds Directory
    │   ├── BrqRV_EB1                       #    User Design gds


### Testing of Design

Go to verilog/dv/BrqRV_EB1/ directory

1. Set the GCC_PATH environment variable.
2. Set the PDK_PATH environment variable.
3. Copy the given program hex file into uart.hex. 
4. run the make commad for RTL simulation
5. run the SIM=GL make command for netlist simulation

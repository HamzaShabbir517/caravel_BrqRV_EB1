# BrqRV EB1 RISC-V Core 1.0 from MERL

This repository contains the brqrv eb1 Core design RTL. Brqrv Eb1 Is A Machine-Mode (M-Mode) Only, 32-Bit Cpu Small Core Which Supports Risc-V’s Integer (I), Compressed Instruction (C), Multiplication And Division (M), And Instruction-Fetch Fence, And Csr Extensions. The Core Contains A 4-Stage, Scalar, In-Order Pipeline

## Block Diagram
![](docs/BrqRV_EB1.png)

## Directory Structure

    ├── configs                 # Configurations Dir
    │   └── snapshots           # Where generated configuration files are created
    ├── design                  # Design root dir
    │   ├── dbg                 #   Debugger
    │   ├── dec                 #   Decode, Registers and Exceptions
    │   ├── dmi                 #   DMI block
    │   ├── exu                 #   EXU (ALU/MUL/DIV)
    │   ├── ifu                 #   Fetch & Branch Prediction
    │   ├── include             
    │   ├── lib
    │   └── lsu                 #   Load/Store
    ├── docs
    ├── tools                   # Scripts/Makefiles
    └── testbench               # (Very) simple testbench
        ├── asm                 #   Example assembly files
        ├── hex                 #   Canned demo hex files
        └── tests               #   Example tests
 
## Dependencies

- Verilator **(4.102 or later)** must be installed on the system if running with verilator
- If adding/removing instructions, espresso must be installed (used by *tools/coredecode*)
- RISCV tool chain (based on gcc version 8.3 or higher) must be
installed so that it can be used to prepare RISCV binaries to run.

## Quickstart guide
1. Clone the repository
1. Setup RV_ROOT to point to the path in your local filesystem
1. Determine your configuration {optional}
1. Run make with tools/Makefile


### Configurations

BrqRV can be configured by running the `$RV_ROOT/configs/brqrv.config` script:

`% $RV_ROOT/configs/brqrv.config -h` for detailed help options

For example to build with a DCCM of size 64 Kb:  

`% $RV_ROOT/configs/brqrv.config -dccm_size=64`  

This will update the **default** snapshot in $RV_ROOT/configs/snapshots/default/ with parameters for a 64K DCCM.  

Add `-snapshot=dccm64`, for example, if you wish to name your build snapshot *dccm64* and refer to it during the build.  


This script derives the following consistent set of include files :  

    $RV_ROOT/configs/snapshots/default
    ├── common_defines.vh                       # `defines for testbench or design
    ├── defines.h                               # #defines for C/assembly headers
    ├── eb1_param.vh                            # Design parameters
    ├── eb1_pdef.vh                             # Parameter structure
    ├── pd_defines.vh                           # `defines for physical design
    ├── perl_configs.pl                         # Perl %configs hash for scripting
    ├── pic_map_auto.h                          # PIC memory map based on configure size
    └── whisper.json                            # JSON file for brqrv-iss
    └── link.ld                                 # default linker control file



### Building a model

while in a work directory:

1. Set the RV_ROOT environment variable to the root of the brqrv directory structure.
Example for bash shell:  
    `export RV_ROOT=/path/to/brqrv`  
Example for csh or its derivatives:  
    `setenv RV_ROOT /path/to/brqrv`
    
1. Create your specific configuration

    *(Skip if default is sufficient)*  
    *(Name your snapshot to distinguish it from the default. Without an explicit name, it will update/override the __default__ snapshot)* 
    For example if `mybuild` is the name for the snapshot:

    set BUILD_PATH environment variable:
    
    `setenv BUILD_PATH snapshots/mybuild`
     
    `$RV_ROOT/configs/brqrv.config [configuration options..] -snapshot=mybuild`  
    
    Snapshots are placed in `$BUILD_PATH` directory


1. Running a simple Hello World program (verilator)

    `make -f $RV_ROOT/tools/Makefile`

This command will build a verilator model of brqrv eb1 with AXI bus, and
execute a short sequence of instructions that writes out "HELLO WORLD"
to the bus.

    
The simulation produces output on the screen like:
```

VerilatorTB: Start of sim

----------------------------------
Hello World from brqrv eb1 @WDC !!
----------------------------------
TEST_PASSED

Finished : minstret = 437, mcycle = 922
See "exec.log" for execution trace with register updates..

```
The simulation generates following files:

 `console.log` contains what the cpu writes to the console address of 0xd0580000.  
 `exec.log` shows instruction trace with GPR updates.  
 `trace_port.csv` contains a log of the trace port.  
 When `debug=1` is provided, a vcd file `sim.vcd` is created and can be browsed by 
  gtkwave or similar waveform viewers.
  
You can re-execute simulation using:  
    `make -f $RV_ROOT/tools/Makefile verilator`


The simulation run/build command has following generic form:

    make -f $RV_ROOT/tools/Makefile [<simulator>] [debug=1] [snapshot=mybuild] [target=<target>] [TEST=<test>] [TEST_DIR=<path_to_test_dir>]

where:
``` 
<simulator> -  can be 'verilator' (by default) 'irun' - Cadence xrun, 'vcs' - Synopsys VCS, 'vlog' Mentor Questa
               'riviera'- Aldec Riviera-PRO. if not provided, 'make' cleans work directory, builds verilator executable and runs a test.
debug=1     -  allows VCD generation for verilator and VCS and SHM waves for irun option.
<target>    -  predefined CPU configurations 'default' ( by default), 'default_ahb', 'typical_pd', 'high_perf' 
TEST        -  allows to run a C (<test>.c) or assembly (<test>.s) test, hello_world is run by default 
TEST_DIR    -  alternative to test source directory testbench/asm or testbench/tests
<snapshot>  -  run and build executable model of custom CPU configuration, remember to provide 'snapshot' argument 
               for runs on custom configurations.
CONF_PARAMS -  allows to provide -set options to brqrv.conf script to alter predefined eb1 targets parameters
```
Example:
     
    make -f $RV_ROOT/tools/Makefile verilator TEST=cmark

will build and simulate  testbench/asm/cmark.c program with verilator 


If you want to compile a test only, you can run:

    make -f $RV_ROOT/tools/Makefile program.hex TEST=<test> [TEST_DIR=/path/to/dir]


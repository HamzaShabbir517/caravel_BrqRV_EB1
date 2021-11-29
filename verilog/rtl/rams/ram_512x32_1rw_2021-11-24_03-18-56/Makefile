XRUN = xrun
VCS  = vcs
IV   = iverilog

all: clean iverilog

iverilog:
	iverilog -o test sky130_sram_1kbyte_1rw1r_32x256_8.v ram* utils.vh
	vvp test
	rm -f *.mif *.hex *.vvp test
	
xrun:
	xrun -gui -xprop F utils.vh sky130_sram_1kbyte_1rw1r_32x256_8.v ram* -access +rwc
	
clean:
	rm -f *.mif *.hex *.vvp *.vcd *.txt test

.PHONY: clean

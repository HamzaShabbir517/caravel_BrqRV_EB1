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

`default_nettype wire

`timescale 1 ns / 1 ps

`include "uprj_netlists.v"
`include "caravel_netlists.v"
`include "spiflash.v"
//`include "tb_prog.v"

module BrqRV_EB1_tb();
    reg clock;
    reg RSTB;
    reg CSB;
    reg power1, power2;
    reg power3, power4;
    
    wire gpio;
    wire [37:0] mprj_io;

    wire [7:0] mprj_io_0;
    wire mprj_ready;
    reg [31:0] count;
    
    assign mprj_io_0 = mprj_io[34:27];
    assign mprj_ready = mprj_io[37];
    
    assign mprj_io[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;
    assign mprj_io[8] = (mprj_ready) ? 1'b0 : 1'b1;
    assign mprj_io[9] = (mprj_ready) ? 1'b1 : 1'b1;
    assign mprj_io[10] = (mprj_ready) ? 1'b1 : 1'b1;
    assign mprj_io[35] = 1'b1;
    assign mprj_io[26:11] = (mprj_ready) ? count : 16'h0000;
    
    always #12.5 clock <= (clock === 1'b0);
    
    initial begin
        clock = 0;
        count = 0;
    end
 
    always @(posedge clock) begin
    	if(mprj_ready) begin
    		count = count + 32'd1;
    	end
    end
    		
    initial begin
        $dumpfile("BrqRV_EB1.vcd");
        $dumpvars(0, BrqRV_EB1_tb);

        // Repeat cycles of 1000 clock edges as needed to complete testbench
        //repeat (300) begin
        //    repeat (1000) @(posedge clock);
        //end
        //$display("%c[1;31m",27);
        //$display ("Monitor: Timeout, Test Project IO Stimulus (RTL) Failed");
        //$display("%c[0m",27);
        //$finish;
    end

	initial begin
	    $display("I am not ready");
	    wait(mprj_ready == 1'b1)
	    $display("I am ready");
	    // Memory output
	    //wait(mprj_io_0 == 8'h00);
	    //wait(mprj_io_0 == 8'h01);
	    //wait(mprj_io_0 == 8'h02);
	    //wait(mprj_io_0 == 8'h03);
	    //wait(mprj_io_0 == 8'h04);
	    //wait(mprj_io_0 == 8'h05);
	    //wait(mprj_io_0 == 8'h06);
	    //wait(mprj_io_0 == 8'h07);
	    //wait(mprj_io_0 == 8'h08);
	    wait(mprj_io_0 == 8'h99);
	    // Observe Output pins [35:8] for factorial
	    /*wait(mprj_io_0 == 28'h0000001);
	    wait(mprj_io_0 == 28'h0000002);
	    wait(mprj_io_0 == 28'h0000006);
    	    wait(mprj_io_0 == 28'h0000018);
	    wait(mprj_io_0 == 28'h0000078);
            wait(mprj_io_0 == 28'h00002D0);
	    wait(mprj_io_0 == 28'h00013B0);
            wait(mprj_io_0 == 28'h0009D80);
	    wait(mprj_io_0 == 28'h0058980);
            wait(mprj_io_0 == 28'h0375F00);
            */
            // Observe Output pins [35:8] for prime_num
	    /*wait(mprj_io_0 == 28'd1);
	    wait(mprj_io_0 == 28'd3);
	    wait(mprj_io_0 == 28'd5);
    	    wait(mprj_io_0 == 28'd7);
	    wait(mprj_io_0 == 28'd11);
            wait(mprj_io_0 == 28'd13);
            */
            // Observe Output pins [35:8] for multliplication_table
            /*wait(mprj_io_0 == 28'd5);
            wait(mprj_io_0 == 28'd10);
            wait(mprj_io_0 == 28'd15);
            wait(mprj_io_0 == 28'd20);
            wait(mprj_io_0 == 28'd25);
            wait(mprj_io_0 == 28'd30);
            */
            // Observe Output pins [35:8] for mean & Determinant
           // wait(mprj_io_0 == 28'd5);
            
            // Observe Output pins [35:8] for power
            //wait(mprj_io_0 == 28'd64);
            
            // Observe Output pins [35:8] for flip number
            //wait(mprj_io_0 == 28'd4889874);
            
            // Observe Output pins [35:8] for Queue 
            /*wait(mprj_io_0 == 28'd5);
            wait(mprj_io_0 == 28'd6);
            wait(mprj_io_0 == 28'd7);
            */
            // Observe Output pins [35:8] for perfect square
            //wait(mprj_io_0 == 28'd5);
            
            // Observe Output pins [35:8] for counter / ascending
            /*wait(mprj_io_0 == 28'd0);
            wait(mprj_io_0 == 28'd1);
            wait(mprj_io_0 == 28'd2);
            wait(mprj_io_0 == 28'd3);
            wait(mprj_io_0 == 28'd4);
            wait(mprj_io_0 == 28'd5);
            wait(mprj_io_0 == 28'd6);
            wait(mprj_io_0 == 28'd7);
            wait(mprj_io_0 == 28'd8);
            wait(mprj_io_0 == 28'd9);
            wait(mprj_io_0 == 28'd10);
            wait(mprj_io_0 == 28'd11);
            */
            // Observe Output pin [35:8] for reverse
            /*wait(mprj_io_0 == 28'd15);
            wait(mprj_io_0 == 28'd14);
            wait(mprj_io_0 == 28'd13);
            wait(mprj_io_0 == 28'd12);
            wait(mprj_io_0 == 28'd11);
            wait(mprj_io_0 == 28'd10);
            wait(mprj_io_0 == 28'd9);
            wait(mprj_io_0 == 28'd8);
            wait(mprj_io_0 == 28'd7);
            wait(mprj_io_0 == 28'd6);
            wait(mprj_io_0 == 28'd5);
            wait(mprj_io_0 == 28'd4); 
            wait(mprj_io_0 == 28'd3);
            wait(mprj_io_0 == 28'd2);
            wait(mprj_io_0 == 28'd1);
            wait(mprj_io_0 == 28'd0);
            */
            //$display("MPRJ-IO state = %d", mprj_io[35:8]);  
		
		`ifdef GL
	    	$display("Monitor: Test 1 Mega-Project IO (GL) Passed");
		`else
		    $display("Monitor: Test 1 Mega-Project IO (RTL) Passed");
		`endif
	    $finish;
	end
	
	// Reset Operation
    initial begin
        RSTB <= 1'b0;
        CSB  <= 1'b1;       // Force CSB high
        #2000;
        RSTB <= 1'b1;       // Release reset
        #170000;
        CSB = 1'b0;         // CSB can be released
    end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end
	
	always @(mprj_io) begin
		$display("MPRJ-IO state = %h, at time = %0t  ", mprj_io[34:27], $time);
	end
	
	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;
	//assign mprj_io[3:0] = 4'h0;

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

       	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
        	.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("BrqRV_EB1.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);
	
	
	/*uartprog #(
		.FILENAME("../hex/uart.hex")
	) prog_uut (
		//.clk(clock),
		.mprj_ready (mprj_ready),
		.r_Rx_Serial (r_Rx_Serial)
	);*/

endmodule
`default_nettype wire
    

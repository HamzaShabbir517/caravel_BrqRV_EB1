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

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,
 
    
    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,
    
    // Independent clock (on independent integer divider)
    input   user_clock2,
    
    // IRQ
    output [2:0] user_irq
);
    wire clk;
    wire rst;
    reg csb0;
    reg csb1;
    reg web; 
    wire [15:0] addr;
    wire [31:0] din;
    wire [63:0] dout0;
    wire [31:0] dout1;


    // WB MI A
    assign wbs_ack_o = 1'b0; // Unused
    assign wbs_dat_o = 32'h00000000;  // Unused


    // IO
    //assign io_out[35:8] = (| lsu_axi_wstrb[3:0]) ? lsu_axi_wdata[27:0] : (| lsu_axi_wstrb[7:4]) ? lsu_axi_wdata[59:32] : {28{1'b0}};
    
    // io_oeb 0 for output 1 for input
    
    assign io_oeb[3:0]  = 4'hf;
    assign io_oeb[4]    = 1'b0;
    assign io_oeb[6:5]  = 2'b01;
    assign io_oeb[7]    = 1'b0;
    assign io_oeb[8]    = 1'b1; // csb0 for M0
    assign io_oeb[9]    = 1'b1; // csb1 for M1
    assign io_oeb[10]    = 1'b1; // web
    assign io_oeb[26:11]    = 16'hFFFF; // addr
    assign io_oeb[34:27]    = 8'h00; // data out
    assign io_oeb[35]    = 1'b1; // output selector // if 0 so output will map on la_data if 1 so will map on io ports
    // IRQ
    assign user_irq = 3'b000;	// Unused


    // Assuming LA probes [65:64] are for controlling the clk & reset  
    assign clk = (~la_oenb[65]) ? la_data_in[65] :  wb_clk_i;
    assign rst = (~la_oenb[64]) ? la_data_in[64] :  wb_rst_i;
    always @(negedge clk) begin
    	csb0 <= (~la_oenb[0]) ? la_data_in[0] : io_in[8];
    	csb1 <= (~la_oenb[1]) ? la_data_in[1] : io_in[9];
    	web <= (~la_oenb[2]) ? la_data_in[2] : io_in[10];
    end
    assign addr = (~la_oenb[18:3]) ? la_data_in[18:3] : io_in[26:11];
    assign din = la_data_in[50:19];    
    assign la_data_out[97:66] = (csb0 == 1'b0 & web == 1'b1 & ~io_in[35]) ? dout0[31:0] : (csb1 == 1'b0 & web == 1'b1 & ~io_in[35]) ? dout1 : 32'h00000000;
    assign la_data_out[61:52] = (csb0 == 1'b0 & web == 1'b1 & ~io_in[35]) ? dout0[41:32] : 10'h000;
    assign la_data_out[119:98] = (csb0 == 1'b0 & web == 1'b1 & ~io_in[35]) ? dout0[63:42] : 22'h000000;
    assign io_out[34:27] = (csb0 == 1'b0 & web == 1'b1 & io_in[35]) ? {dout0[35:32],dout0[3:0]} : (csb1 == 1'b0 & web == 1'b1 & io_in[35]) ? dout1[7:0] : 8'h00;
    

    
    /*always @posedge(clk) begin
    if(rst) begin
    state <= 2'b00; // IDLE
    end
    else begin
    state <= next_state;
    end
    */
    /*// IDLE = 3'b000, READ_M1 = 3'b001, WRITE_M1 = 3'b010, READ_M2 = 3'b011, WRITE_M2 = 3'b100, COMPLETE = 3'b101 
    case(state) begin
    3'b000 : begin
            next_state = (csb0==1'b0 & web == 1'b1) ? 3'b001 : (csb0==1'b0 & web == 1'b0) ? 3'b010 : (csb1==1'b0 & web == 1'b1) ? 3'b011 : (csb1==1'b0 & web == 1'b0) ? 3'b100 : 3'b00;
     	     wmask <= 4'h0;
     	     din <= 32'h00000000;
     	     count <= 3'h0;      
            end
            
     3'b001 : begin
     	     next_state = (count <= 3'h7) : 3'b101 :  
      */ 
              
   //=========================================================================-
   // RTL instance
   //=========================================================================-

ram_generic_nr1w 
ram_2r1w_256x32 ( `ifdef USE_POWER_PINS
    .vccd1		     ( vccd1	      ),
    .vssd1                   ( vssd1         ),
  `endif
    .clk(clk),
    .csb(csb0),
    .web(web),
    .wmask(4'hF),
    .din(din),
    .addr(addr),
    .dout(dout0),
    .addr1(addr), 
    .csb1(1'b1),
    .clk1(clk), 
    .dout1()
    );

sky130_sram_1kbyte_1rw1r_32x256_8 sram (`ifdef USE_POWER_PINS
    .vccd1(vccd1),
    .vssd1(vssd1),
`endif
					 .clk0(clk),
					 .csb0(csb1),
					 .web0(web),
					 .wmask0(4'hf),
					 .addr0(addr[7:0]),
					 .din0(din),
					 .dout0(dout1),
    					 .clk1(clk),
    					 .csb1(1'b1),
    					 .addr1(addr[7:0]),
    					 .dout1() 
    					 );				 
endmodule


`default_nettype wire

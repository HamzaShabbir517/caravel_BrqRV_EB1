`include "utils.vh"
module ram_generic_nr1w
 #(  parameter NUM_WMASKS    = 4,
     parameter MEMD = 512,
     parameter DATA_WIDTH    = 32, // data width
     parameter nRPORTS = 2 , // number of reading ports
     parameter nWPORTS = 1, // number of write ports
     parameter IZERO   = 0 , // binary / Initial RAM with zeros (has priority over IFILE)
     parameter IFILE   = "",  // initialization mif file (don't pass extension), optional
     parameter BASIC_MODEL = 256,
     parameter ADDR_WIDTH = 9,
     parameter DELAY = 3,
     parameter BYPASS = 1
  )( `ifdef USE_POWER_PINS
  vccd1,
  vssd1,
`endif
  addr, clk, csb, web, wmask, din, dout, addr1, csb1, clk1, dout1);
  `ifdef USE_POWER_PINS
  inout vccd1;
  inout vssd1;
  `endif
  input  clk; // clock
  input  csb; // active low chip select
  input  web; // active low write control
  input [NUM_WMASKS-1:0]  wmask; // write mask
  input [ADDR_WIDTH * nRPORTS-1:0] addr;
  input [DATA_WIDTH-1:0]  din;
  output reg [DATA_WIDTH*nRPORTS-1:0]  dout;
  input clk1;
  input csb1;
  input [ADDR_WIDTH * nRPORTS-1:0] addr1;
  output reg [DATA_WIDTH*nRPORTS-1:0]  dout1;
    // unpacked read addresses/data
  reg  [ADDR_WIDTH-1:0] RAddr_upk [nRPORTS-1:0]; // read addresses - unpacked 2D array 
  wire [DATA_WIDTH-1:0] RData_upk [nRPORTS-1:0]; // read data      - unpacked 2D array 
  reg  [ADDR_WIDTH-1:0] RAddr_upk_1 [nRPORTS-1:0]; // read addresses - unpacked 2D array 
  wire [DATA_WIDTH-1:0] RData_upk_1 [nRPORTS-1:0]; // read data      - unpacked 2D array 

  // unpack read addresses; pack read data
  `ARRINIT;
  always @* begin
    `ARR1D2D(nRPORTS,ADDR_WIDTH,addr,RAddr_upk);
    `ARR2D1D(nRPORTS,DATA_WIDTH,RData_upk,dout);
    `ARR1D2D(nRPORTS,ADDR_WIDTH,addr1,RAddr_upk_1);
    `ARR2D1D(nRPORTS,DATA_WIDTH,RData_upk_1,dout1);
  end
genvar rpi;
  generate
    for (rpi=0 ; rpi<nRPORTS; rpi=rpi+1) begin
    ram_generic_1rw #( .NUM_WMASKS (NUM_WMASKS),
     		    .MEMD(MEMD),
     		    .DATA_WIDTH(DATA_WIDTH), // data width
                    .nRPORTS(1), // number of reading ports
      		    .nWPORTS(1), // number of write ports
     		    .IZERO  (IZERO), // binary / Initial RAM with zeros (has priority over IFILE)
    		    .IFILE   (IFILE),  // initialization mif file (don't pass extension), optional
     		    .BASIC_MODEL (BASIC_MODEL),
         	    .ADDR_WIDTH(ADDR_WIDTH),
     		    .DELAY (DELAY),
     		    .BYPASS(BYPASS))
    ram_1rw      ( `ifdef USE_POWER_PINS
    		    .vccd1(vccd1),
    		    .vssd1(vssd1),
    		    `endif
    		    .clk(clk), // clock
  		    .csb(csb), // active low chip select
  		    .web(web), // active low write control
  		    .wmask(wmask), // write mask
  		    .addr(RAddr_upk[rpi]/*(web == 0) ? RAddr_upk[0] : RAddr_upk[rpi]*/),
  		    .din(din),
   		    .dout(RData_upk[rpi]),
                    .clk1(clk1),
                    .csb1(csb1), 
                    .addr1(RAddr_upk_1[rpi]),
                    .dout1(RData_upk_1[rpi]));
    end
  endgenerate
endmodule


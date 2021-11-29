// ceiling of log2
`define log2(x)  ( ( ((x) >  1      ) ? 1  : 0) + \
                   ( ((x) >  2      ) ? 1  : 0) + \
                   ( ((x) >  4      ) ? 1  : 0) + \
                   ( ((x) >  8      ) ? 1  : 0) + \
                   ( ((x) >  16     ) ? 1  : 0) + \
                   ( ((x) >  32     ) ? 1  : 0) + \
                   ( ((x) >  64     ) ? 1  : 0) + \
                   ( ((x) >  128    ) ? 1  : 0) + \
                   ( ((x) >  256    ) ? 1  : 0) + \
                   ( ((x) >  512    ) ? 1  : 0) + \
                   ( ((x) >  1024   ) ? 1  : 0) + \
                   ( ((x) >  2048   ) ? 1  : 0) + \
                   ( ((x) >  4096   ) ? 1  : 0) + \
                   ( ((x) >  8192   ) ? 1  : 0) + \
                   ( ((x) >  16384  ) ? 1  : 0) + \
                   ( ((x) >  32768  ) ? 1  : 0) + \
                   ( ((x) >  65536  ) ? 1  : 0) + \
                   ( ((x) >  131072 ) ? 1  : 0) + \
                   ( ((x) >  262144 ) ? 1  : 0) + \
                   ( ((x) >  524288 ) ? 1  : 0) + \
                   ( ((x) >  1048576) ? 1  : 0) + \
                   ( ((x) >  2097152) ? 1  : 0) + \
                   ( ((x) >  4194304) ? 1  : 0)   )
                   
//`include "utils.vh"
module ram_generic_1rw
 #(  parameter NUM_WMASKS    = 4,
     parameter MEMD = 256,
     parameter DATA_WIDTH    = 32, // data width
     parameter nRPORTS = 1 , // number of reading ports
     parameter nWPORTS = 1, // number of write ports
     parameter IZERO   = 0 , // binary / Initial RAM with zeros (has priority over IFILE)
     parameter IFILE   = "",  // initialization mif file (don't pass extension), optional
     parameter BASIC_MODEL = 256,
     parameter ADDR_WIDTH = 8,
     parameter BASIC_DATA_WIDTH = 32,
     parameter fixed_width = 0,
     parameter DELAY = 3,
     parameter BYPASS = 1
  )( `ifdef USE_POWER_PINS
  inout vccd1,
  inout vssd1,
`endif
  input  clk, // clock
  input  csb, // active low chip select
  input  web, // active low write control
  input [NUM_WMASKS-1:0]  wmask, // write mask
  input [ADDR_WIDTH-1:0]  addr,
  input [DATA_WIDTH-1:0]  din,
  output reg[DATA_WIDTH-1:0]  dout,
  input clk1,
  input csb1,
  input [ADDR_WIDTH-1:0] addr1,
  output reg [DATA_WIDTH-1:0] dout1);

localparam ADDRW = ADDR_WIDTH; // address width
localparam NUM_OF_BANKS = MEMD / BASIC_MODEL;
localparam Basic_ADDRW = `log2(BASIC_MODEL); // address width
localparam horizontal_banks = DATA_WIDTH / BASIC_DATA_WIDTH;

reg [DATA_WIDTH-1:0] RData_out;
wire[DATA_WIDTH-1:0] Rdata [NUM_OF_BANKS-1:0];
wire [$clog2(NUM_OF_BANKS):0] Addr_sel;
reg  [$clog2(NUM_OF_BANKS):0] Raddr_sel; 
reg [Basic_ADDRW-1:0] Addr [NUM_OF_BANKS-1:0];
reg wen [NUM_OF_BANKS-1:0];
reg csb_i [NUM_OF_BANKS-1:0];
reg web_reg;

// port  2
reg [DATA_WIDTH-1:0] RData_out_1;
wire[DATA_WIDTH-1:0] Rdata_1 [NUM_OF_BANKS-1:0];
wire [$clog2(NUM_OF_BANKS):0] Addr_sel_1;
reg  [$clog2(NUM_OF_BANKS):0] Raddr_sel_1;
reg [Basic_ADDRW-1:0] Addr_1 [NUM_OF_BANKS-1:0];
reg csb_i_1 [NUM_OF_BANKS-1:0];


assign Addr_sel = addr / BASIC_MODEL;//addr % NUM_OF_BANKS;
assign Addr_sel_1 = addr1 / BASIC_MODEL; 

always @(posedge clk) begin
Raddr_sel <= addr / BASIC_MODEL; // addr % NUM_OF_BANKS;
Raddr_sel_1 <= addr1 / BASIC_MODEL;
web_reg <= web;
end

integer i;
integer j;

 always @(Addr_sel or addr or web or csb) begin
	for(i=0; i<NUM_OF_BANKS; i=i+1) begin
	Addr[i] = (Addr_sel == i) ? addr : 0;
        wen[i] = (Addr_sel == i) ? web : 1;
	csb_i[i] = (Addr_sel == i) ? csb : 1;
	end
end

always @(Addr_sel_1 or addr1 or csb1) begin
	for(i=0; i<NUM_OF_BANKS; i=i+1) begin
        Addr_1[i] = (Addr_sel_1 == i) ? addr1 : 0;
        csb_i_1[i] = (Addr_sel_1 == i) ? csb1 : 1;
	end
end

genvar p,h;
generate
	for(p=0; p<NUM_OF_BANKS; p=p+1) begin
		if(fixed_width == 32'h00000001) begin
			for(h=0; h<horizontal_banks; h=h+1) begin
			
			sky130_sram_1kbyte_1rw1r_32x256_8 
				ram_i ( `ifdef USE_POWER_PINS
					.vccd1(vccd1),
					.vssd1(vssd1),
					`endif
					.clk0(clk),
					.csb0(csb_i[p]),
					.web0(wen[p]),
					.wmask0(wmask[4*h +: 4]),
					.addr0(Addr[p]),
					.din0(din[BASIC_DATA_WIDTH*h +: BASIC_DATA_WIDTH]),
					.dout0(Rdata[p][BASIC_DATA_WIDTH*h +: BASIC_DATA_WIDTH]),
               		        .clk1(clk1),
               		        .csb1(csb_i_1[p]),
               		        .addr1(Addr_1[p]),
               		        .dout1(Rdata_1[p][BASIC_DATA_WIDTH*h +: BASIC_DATA_WIDTH]));
             		end
             	end
             	else begin
             		sky130_sram_1kbyte_1rw1r_32x256_8 
				ram_i ( `ifdef USE_POWER_PINS
					.vccd1(vccd1),
					.vssd1(vssd1),
					`endif
					.clk0(clk),
					.csb0(csb_i[p]),
					.web0(wen[p]),
					.wmask0(wmask),
					.addr0(Addr[p]),
					.din0(din),
					.dout0(Rdata[p]),
               		        .clk1(clk1),
               		        .csb1(csb_i_1[p]),
               		        .addr1(Addr_1[p]),
               		        .dout1(Rdata_1[p]));
               end
               	        
	end
endgenerate

always @(posedge clk) begin
        if(web_reg==1) begin
	for(j=0; j<NUM_OF_BANKS; j=j+1) begin
	 RData_out = (Raddr_sel == j) ? Rdata[j] : RData_out;
	end
        end
        else
         RData_out = RData_out;
        // Port 2
end
always @(posedge clk) begin 
        for(j=0; j<NUM_OF_BANKS; j=j+1) begin
        //RData_out_1 = (Raddr_sel_1 == q) ? Rdata_1[q] : RData_out_1;
	if(Raddr_sel_1 == j) 
        RData_out_1 = Rdata_1[j];
        else
        RData_out_1 = RData_out_1;	
	end
end

always @* begin
dout = RData_out;
end


always @* begin 
dout1 = RData_out_1;
end

endmodule



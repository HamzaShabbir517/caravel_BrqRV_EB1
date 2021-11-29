`include "utils.vh"

// set default value for the following parameters, if not defined from command-line
// memory depth
`ifndef WMASK
`define WMASK   4
`endif

`ifndef MEMD
`define MEMD   512
`endif
// data width
`ifndef DATAW
`define DATAW   32
`endif
// number of reading ports
`ifndef nWPORTS
`define nWPORTS 1
`endif
// number of writing ports
`ifndef nRPORTS
`define nRPORTS 2
`endif
// Simulation cycles count
`ifndef CYCC
`define CYCC 1000
`endif

`ifndef Basic_Model
`define Basic_Model 256
`endif

`ifndef ADDRW 
`define ADDRW 9
`endif

// WDW (Write-During-Write) protection
`ifndef WDW
`define WDW 0
`endif

// WAW (Write-After-Write) protection
`ifndef WAW
`define WAW 1
`endif

// RDW (Read-During-Write) protection
`ifndef RDW
`define RDW 1
`endif

// RAW (Read-After-Write) protection
`ifndef RAW
`define RAW 1
`endif

module ram_generic_nr1w_tb;

  localparam MEMD    = `MEMD         ; // memory depth
  localparam DATAW   = `DATAW        ; // data width
  localparam nRPORTS = `nRPORTS      ; // number of reading ports
  localparam nWPORTS = `nWPORTS      ; // number of writing ports
  localparam CYCC    = `CYCC         ; // simulation cycles count
  
  localparam ADDRW  = `ADDRW; // address size
  localparam VERBOSE = 0             ; // verbose logging (1:yes; 0:no)
  localparam CYCT    = 10            ; // cycle      time
  localparam RSTT    = 5.2*CYCT      ; // reset      time
  localparam TERFAIL = 0             ; // terminate if fail?
  localparam TIMEOUT = 2*CYCT*CYCC   ; // simulation time
  localparam BASIC_MODEL = `Basic_Model;
  reg                      clk = 1'b0                    ; // global clock
  reg                      rst = 1'b1                    ; // global reset
  reg  [nWPORTS-1:0      ] WEnb                          ; // write enable for each writing port
  reg  [ADDRW*nWPORTS-1:0] WAddr_pck                     ; // write addresses - packed from nWPORTS write ports
  reg  [ADDRW-1:0        ] WAddr_upk        [nWPORTS-1:0]; // write addresses - unpacked 2D array 
  reg  [ADDRW*nRPORTS-1:0] RAddr_pck                     ; // read  addresses - packed from nRPORTS  read  ports
  reg  [ADDRW-1:0        ] RAddr_upk        [nRPORTS-1:0]; // read  addresses - unpacked 2D array 
  reg  [DATAW*nWPORTS-1:0] WData_pck                     ; // write data - packed from nWPORTS read ports
  reg  [DATAW-1:0        ] WData_upk        [nWPORTS-1:0]; // write data - unpacked 2D array 
  wire [DATAW*nRPORTS-1:0] RData_pck_sram             ; // read  data - packed from nRPORTS read ports
  reg  [DATAW-1:0        ] RData_upk_sram [nRPORTS-1:0]; // read  data - unpacked 2D array 
  reg [DATAW*nRPORTS-1:0] RData_pck_golden             ; // read  data - packed from nRPORTS read ports
  reg  [DATAW-1:0        ] RData_upk_golden [nRPORTS-1:0]; // read  data - unpacked 2D array 
  reg  [`WMASK*nWPORTS-1:0] wmask_pck	    		  ; // wmask packed
  reg  [`WMASK-1:0        ] wmask_upk	     [nWPORTS-1:0]; // wmask unpacked
  integer i,j; // general indeces

 // generates random ram hex/mif initializing files
  task genInitFiles;
    input [31  :0] DEPTH  ; // memory depth
    input [31  :0] WIDTH  ; // memoty width
    input [255 :0] INITVAL; // initial vlaue (if not random)
    input          RAND   ; // random value?
    input [1:8*20] FILEN  ; // memory initializing file name
    reg   [255 :0] ramdata;
    integer addr,hex_fd,mif_fd;
    begin
      // open hex/mif file descriptors
      hex_fd = $fopen({FILEN,".hex"},"w");
      mif_fd = $fopen({FILEN,".mif"},"w");
      // write mif header
      $fwrite(mif_fd,"WIDTH         = %0d;\n",WIDTH);
      $fwrite(mif_fd,"DEPTH         = %0d;\n",DEPTH);
      $fwrite(mif_fd,"ADDRESS_RADIX = HEX;\n"     );
      $fwrite(mif_fd,"DATA_RADIX    = HEX;\n\n"   );
      $fwrite(mif_fd,"CONTENT BEGIN\n"            );
      // write random memory lines
      for(addr=0;addr<DEPTH;addr=addr+1) begin
        if (RAND) begin
          `GETRAND(ramdata,WIDTH); 
        end else ramdata = INITVAL;
        $fwrite(hex_fd,"%0h\n",ramdata);
        $fwrite(mif_fd,"  %0h :  %0h;\n",addr,ramdata);
      end
      // write mif tail
      $fwrite(mif_fd,"END;\n");
      // close hex/mif file descriptors
      $fclose(hex_fd);
      $fclose(mif_fd);
    end
  endtask
  
   
  initial begin
  	$dumpfile("srimulation.vcd");
  	$dumpvars(0,ram_generic_nr1w_tb);
  end

  integer rep_fd, ferr;
  initial begin
    // write header
    //rep_fd = $fopen("sim.txt","r"); // try to open report file for read
    //$ferror(rep_fd,ferr);       // detect error
    //$fclose(rep_fd);
    rep_fd = $fopen("sim.txt","w"); // open report file for append
    if (1) begin     // if file is new (can't open for read); write header
      $fwrite(rep_fd,"===============================Simulation Results======================================\n");
      $fwrite(rep_fd,"=======================================================================================\n");
      $fwrite(rep_fd,"Golden   Golden     Golden          Actual       Actual     Actual          Result   \n");
      $fwrite(rep_fd,"Read     Model      Model           Read         Model      Model                    \n");
      $fwrite(rep_fd,"Port     RAddr      RData           Port         RAddr      RData                    \n");
      $fwrite(rep_fd,"=======================================================================================\n");
      $fclose(rep_fd);
    end
    $write("Simulating  RAM:\n");
    $write("Write ports  : %0d\n"  ,nWPORTS  );
    $write("Read ports   : %0d\n"  ,nRPORTS  );
    $write("Data width   : %0d\n"  ,DATAW    );
    $write("RAM depth    : %0d\n"  ,MEMD     );
    $write("Address width: %0d\n",ADDRW    );
    $write("Memory Size : %0d KB \n\n", (MEMD*DATAW)/8000);
    // generate random ram hex/mif initializing file
    genInitFiles(MEMD,DATAW   ,0,1,"init_ram");
    // finish simulation
    #(TIMEOUT) begin 
      $write("*** Simulation terminated due to timeout\n");
      $finish;
    end
  end

// generate clock and reset
  always  #(CYCT/2) clk = ~clk; // toggle clock
  initial #(RSTT  ) rst = 1'b0; // lower reset

  // pack/unpack data and addresses
  `ARRINIT;
  always @* begin
    `ARR2D1D(nRPORTS,ADDRW,RAddr_upk        ,RAddr_pck        );
    `ARR2D1D(nWPORTS,`WMASK,wmask_upk        ,wmask_pck        );
    `ARR2D1D(nWPORTS,ADDRW,WAddr_upk        ,WAddr_pck        );
    `ARR1D2D(nWPORTS,DATAW,WData_pck        ,WData_upk        );
    `ARR1D2D(nRPORTS,DATAW,RData_pck_sram   ,RData_upk_sram   );
    `ARR2D1D(nRPORTS,DATAW,RData_upk_golden ,RData_pck_golden );
end

  // register write addresses
  reg  [ADDRW-1:0        ] WAddr_r_upk   [nWPORTS-1:0]; // previous (registerd) write addresses - unpacked 2D array 
  always @(negedge clk)
    //WAddr_r_pck <= WAddr_pck;
    for (i=0;i<nWPORTS;i=i+1) WAddr_r_upk[i] <= WAddr_upk[i];

  // generate random write data and random write/read addresses; on falling edge
  reg wdw_addr; // indicates same write addresses on same cycle (Write-During-Write)
  reg waw_addr; // indicates same write addresses on next cycle (Write-After-Write)
  reg rdw_addr; // indicates same read/write addresses on same cycle (Read-During-Write)
  reg raw_addr; // indicates same read address on next cycle (Read-After-Write)

always @(negedge clk) begin
    // generate random write addresses; different that current and previous write addresses
     for (i=0;i<nWPORTS;i=i+1) begin
      wdw_addr = 1; waw_addr = 1;
      while (wdw_addr || waw_addr) begin
        `GETRAND(WAddr_upk[i],ADDRW);
        wdw_addr = 0; waw_addr = 0;
        if (!`WDW) for (j=0;j<i      ;j=j+1) wdw_addr = wdw_addr || (WAddr_upk[i] == WAddr_upk[j]  );
        if (!`WAW) for (j=0;j<nWPORTS;j=j+1) waw_addr = waw_addr || (WAddr_upk[i] == WAddr_r_upk[j]);
      end
    end

 // generate random read addresses; different that current and previous write addresses
    for (i=0;i<nRPORTS;i=i+1) begin
      rdw_addr = 1; raw_addr = 1;
      while (rdw_addr || raw_addr) begin
        `GETRAND(RAddr_upk[i],ADDRW);
        `GETRAND(wmask_upk[i],      `WMASK); 
        rdw_addr = 0; raw_addr = 0;
        if (!`RDW) for (j=0;j<nWPORTS;j=j+1) rdw_addr = rdw_addr || (RAddr_upk[i] == WAddr_upk[j]  );
        if (!`RAW) for (j=0;j<nWPORTS;j=j+1) raw_addr = raw_addr || (RAddr_upk[i] == WAddr_r_upk[j]);
      end
    end
  // generate random write data and write enables
    `GETRAND(WData_pck,DATAW*nWPORTS);
    `GETRAND(WEnb     ,      nWPORTS); 
	if (rst) WEnb=1'b0; //else WEnb={nWPORTS{1'b1}};
  end

integer cycc=1; // cycles count
integer pass;
integer p;
always @(negedge clk) begin
    if (!rst) begin
        #(CYCT/10) // a little after falling edge
        #(CYCT/2) // a little after rising edge
        
        //if (cycc==CYCC) begin
        for(p=0; p<nRPORTS; p=p+1) begin
            pass = (RData_upk_golden[p]===RData_upk_sram[p]);
    	    rep_fd = $fopen("sim.txt","a+");
            $fwrite(rep_fd,"%-10d %-10d %-15h %-10d %-10d %-15h %-10s \n",p,RAddr_upk[p],RData_upk_golden[p],p,RAddr_upk[p],RData_upk_sram[p],pass?"pass":"fail");
            $fclose(rep_fd);
        end
        if (cycc==CYCC) begin
	$finish;
	end
        cycc=cycc+1;
    end
end

// Golden model of SRAM
integer q,r,s;
reg [DATAW-1:0] mem [0:MEMD-1];
initial begin
//      $readmemh("init_ram.hex", mem);
        for(r=0; r<MEMD; r=r+1) mem[r] = {DATAW{1'b0}};
end
always @(posedge clk)
  begin
    if(WEnb) begin
    	for(s=0; s<`WMASK; s=s+1) begin
    		if(wmask_pck[s])
        		mem[WAddr_pck][8*s +: 8] = WData_pck[8*s +: 8];
    	end
    end
   else begin
      for(q=0; q<nRPORTS; q=q+1) begin
        RData_upk_golden[q] <= #(10) mem[RAddr_upk[q]];
      end
   end
  end


ram_generic_nr1w #( .NUM_WMASKS (`WMASK),
     		    .MEMD(MEMD),
     		    .DATA_WIDTH(DATAW), // data width
                    .nRPORTS(nRPORTS), // number of reading ports
     		    .nWPORTS(nWPORTS), // number of write ports
     		    .IZERO  (1), // binary / Initial RAM with zeros (has priority over IFILE)
    		    .IFILE   (""),  // initialization mif file (don't pass extension), optional
     		    .BASIC_MODEL (BASIC_MODEL),
         	    .ADDR_WIDTH(ADDRW),
     		    .DELAY (3))
ram_nr1w          ( `ifdef USE_POWER_PINS
		    .vccd1(vccd1),
		    .vssd1(vssd1),
		    `endif
		    .clk(clk), // clock
  		    .csb(1'b0), // active low chip select
  		    .web(~WEnb), // active low write control
  		    .wmask(wmask_pck), // write mask
		    .addr((WEnb==1'b1)? {nRPORTS{WAddr_pck}}:RAddr_pck),
  		    .din(WData_pck),
   		    .dout(RData_pck_sram),
                    .clk1(clk),
                    .csb1(1'b1),
                    .addr1({ADDRW*nRPORTS{1'b0}}),
                    .dout1());
endmodule


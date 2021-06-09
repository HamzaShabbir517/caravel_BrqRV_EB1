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
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
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

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;
    wire rx_i;
    wire [31:0] reser_vector;
    wire [31:0] jtag_id;
    wire [31:0] nmi_vector;
    wire nmi_int;
    
    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;
    
    wire		lsu_axi_wvalid;
    wire [63:0]	lsu_axi_wdata;
    wire [7:0]         lsu_axi_wstrb;
    wire		lsu_axi_bvalid;


    // WB MI A
    assign wbs_ack_o = 1'b0; // Unused
    assign wbs_dat_o = 32'h00000000;  // Unused


    // IO
    assign io_out[35:8] = (| lsu_axi_wstrb[3:0]) ? lsu_axi_wdata[27:0] : (| lsu_axi_wstrb[7:4]) ? lsu_axi_wdata[59:32] : {28{1'b0}};
    
    assign io_oeb[35:8] = {28{~lsu_axi_wvalid}};
    assign io_oeb[7:0] = {8{~rst}};
    assign io_oeb[37:36] = {2{~rst}};
    assign lsu_axi_bvalid = (wb_rst_i) ? 1'b0 : (lsu_axi_wvalid) ? 1'b1 : 1'b0;

    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    assign la_data_out = (| lsu_axi_wstrb[3:0]) ? {{(127-BITS){1'b0}}, lsu_axi_wdata[31:0]} : (| lsu_axi_wstrb[7:4]) ? {{(127-BITS){1'b0}}, lsu_axi_wdata[63:32]} : {128{1'b0}};

    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign clk = (~la_oenb[65]) ? la_data_in[65] :  wb_clk_i;
    assign rst = (~la_oenb[64]) ? la_data_in[64] : ~wb_rst_i;
    assign rx_i = io_in[5];
    assign reser_vector = 32'haffff000;
    assign jtag_id[31:28] = 4'b1;
    assign jtag_id[27:12] = {16{1'b0}};
    assign jtag_id[11:1]  = 11'h45;
    assign nmi_vector   = 32'hee000000;
    assign nmi_int   = 0;
    
    
   //=========================================================================-
   // RTL instance
   //=========================================================================-
eb1_brqrv_wrapper brqrv_top (
`ifdef USE_POWER_PINS
    .vccd1		     ( vccd1         ),
    .vssd1		     ( vssd1         ),
`endif
    .rst_l                  ( rst           ),
    .dbg_rst_l              ( 1'b1          ),
    .clk                    ( clk           ),
    .rst_vec                ( reset_vector[31:1]),
    .nmi_int                ( nmi_int       ),
    .nmi_vec                ( nmi_vector[31:1]),
    .jtag_id                ( jtag_id[31:1]),
    .uart_rx		     ( rx_i          ),
    .CLKS_PER_BIT           ( la_data_in[47:32]),

`ifdef RV_BUILD_AHB_LITE
    .haddr                  (      ),
    .hburst                 (      ),
    .hmastlock              (      ),
    .hprot                  (      ),
    .hsize                  (      ),
    .htrans                 (      ),
    .hwrite                 (      ),

    .hrdata                 (      ),
    .hready                 (      ),
    .hresp                  (      ),

    //---------------------------------------------------------------
    // Debug AHB Master
    //---------------------------------------------------------------
    .sb_haddr               (      ),
    .sb_hburst              (      ),
    .sb_hmastlock           (      ),
    .sb_hprot               (      ),
    .sb_hsize               (      ),
    .sb_htrans              (      ),
    .sb_hwrite              (      ),
    .sb_hwdata              (      ),

    .sb_hrdata              (      ),
    .sb_hready              (      ),
    .sb_hresp               (      ),

    //---------------------------------------------------------------
    // LSU AHB Master
    //---------------------------------------------------------------
    .lsu_haddr              (      ),
    .lsu_hburst             (      ),
    .lsu_hmastlock          (      ),
    .lsu_hprot              (      ),
    .lsu_hsize              (      ),
    .lsu_htrans             (      ),
    .lsu_hwrite             (      ),
    .lsu_hwdata             (      ),

    .lsu_hrdata             (      ),
    .lsu_hready             (      ),
    .lsu_hresp              (      ),

    //---------------------------------------------------------------
    // DMA Slave
    //---------------------------------------------------------------
    .dma_haddr              ( '0 ),
    .dma_hburst             ( '0 ),
    .dma_hmastlock          ( '0 ),
    .dma_hprot              ( '0 ),
    .dma_hsize              ( '0 ),
    .dma_htrans             ( '0 ),
    .dma_hwrite             ( '0 ),
    .dma_hwdata             ( '0 ),

    .dma_hrdata             (    ),
    .dma_hresp              (    ),
    .dma_hsel               (1'b1),
    .dma_hreadyin           (    ),
    .dma_hreadyout          (    ),
`endif

    //-------------------------- LSU AXI signals--------------------------
    // AXI Write Channels
    .lsu_axi_awvalid        (),
    .lsu_axi_awready        (1'b1),
    .lsu_axi_awid           (),
    .lsu_axi_awaddr         (),
    .lsu_axi_awregion       (),
    .lsu_axi_awlen          (),
    .lsu_axi_awsize         (),
    .lsu_axi_awburst        (),
    .lsu_axi_awlock         (),
    .lsu_axi_awcache        (),
    .lsu_axi_awprot         (),
    .lsu_axi_awqos          (),

    .lsu_axi_wvalid         (lsu_axi_wvalid),
    .lsu_axi_wready         (1'b1),
    .lsu_axi_wdata          (lsu_axi_wdata),
    .lsu_axi_wstrb          (lsu_axi_wstrb),
    .lsu_axi_wlast          (),

    .lsu_axi_bvalid         (lsu_axi_bvalid),
    .lsu_axi_bready         (1'b1),
    .lsu_axi_bresp          (),
    .lsu_axi_bid            (),


    .lsu_axi_arvalid        (),
    .lsu_axi_arready        (),
    .lsu_axi_arid           (),
    .lsu_axi_araddr         (),
    .lsu_axi_arregion       (),
    .lsu_axi_arlen          (),
    .lsu_axi_arsize         (),
    .lsu_axi_arburst        (),
    .lsu_axi_arlock         (),
    .lsu_axi_arcache        (),
    .lsu_axi_arprot         (),
    .lsu_axi_arqos          (),

    .lsu_axi_rvalid         (),
    .lsu_axi_rready         (),
    .lsu_axi_rid            (),
    .lsu_axi_rdata          (),
    .lsu_axi_rresp          (),
    .lsu_axi_rlast          (),
    
`ifdef RV_BUILD_AXI4
    //-------------------------- IFU AXI signals--------------------------
    // AXI Write Channels
    .ifu_axi_awvalid        (),
    .ifu_axi_awready        (),
    .ifu_axi_awid           (),
    .ifu_axi_awaddr         (),
    .ifu_axi_awregion       (),
    .ifu_axi_awlen          (),
    .ifu_axi_awsize         (),
    .ifu_axi_awburst        (),
    .ifu_axi_awlock         (),
    .ifu_axi_awcache        (),
    .ifu_axi_awprot         (),
    .ifu_axi_awqos          (),

    .ifu_axi_wvalid         (),
    .ifu_axi_wready         (),
    .ifu_axi_wdata          (),
    .ifu_axi_wstrb          (),
    .ifu_axi_wlast          (),

    .ifu_axi_bvalid         (),
    .ifu_axi_bready         (),
    .ifu_axi_bresp          (),
    .ifu_axi_bid            (),

    .ifu_axi_arvalid        (),
    .ifu_axi_arready        (),
    .ifu_axi_arid           (),
    .ifu_axi_araddr         (),
    .ifu_axi_arregion       (),
    .ifu_axi_arlen          (),
    .ifu_axi_arsize         (),
    .ifu_axi_arburst        (),
    .ifu_axi_arlock         (),
    .ifu_axi_arcache        (),
    .ifu_axi_arprot         (),
    .ifu_axi_arqos          (),

    .ifu_axi_rvalid         (),
    .ifu_axi_rready         (),
    .ifu_axi_rid            (),
    .ifu_axi_rdata          (),
    .ifu_axi_rresp          (),
    .ifu_axi_rlast          (),

    //-------------------------- SB AXI signals--------------------------
    // AXI Write Channels
    .sb_axi_awvalid         (),
    .sb_axi_awready         (),
    .sb_axi_awid            (),
    .sb_axi_awaddr          (),
    .sb_axi_awregion        (),
    .sb_axi_awlen           (),
    .sb_axi_awsize          (),
    .sb_axi_awburst         (),
    .sb_axi_awlock          (),
    .sb_axi_awcache         (),
    .sb_axi_awprot          (),
    .sb_axi_awqos           (),

    .sb_axi_wvalid          (),
    .sb_axi_wready          (),
    .sb_axi_wdata           (),
    .sb_axi_wstrb           (),
    .sb_axi_wlast           (),

    .sb_axi_bvalid          (),
    .sb_axi_bready          (),
    .sb_axi_bresp           (),
    .sb_axi_bid             (),


    .sb_axi_arvalid         (),
    .sb_axi_arready         (),
    .sb_axi_arid            (),
    .sb_axi_araddr          (),
    .sb_axi_arregion        (),
    .sb_axi_arlen           (),
    .sb_axi_arsize          (),
    .sb_axi_arburst         (),
    .sb_axi_arlock          (),
    .sb_axi_arcache         (),
    .sb_axi_arprot          (),
    .sb_axi_arqos           (),

    .sb_axi_rvalid          (),
    .sb_axi_rready          (),
    .sb_axi_rid             (),
    .sb_axi_rdata           (),
    .sb_axi_rresp           (),
    .sb_axi_rlast           (),

    //-------------------------- DMA AXI signals--------------------------
    // AXI Write Channels
    .dma_axi_awvalid        (),
    .dma_axi_awready        (),
    .dma_axi_awid           ('0),
    .dma_axi_awaddr         (),
    .dma_axi_awsize         (),
    .dma_axi_awprot         (),
    .dma_axi_awlen          (),
    .dma_axi_awburst        (),


    .dma_axi_wvalid         (),
    .dma_axi_wready         (),
    .dma_axi_wdata          (),
    .dma_axi_wstrb          (),
    .dma_axi_wlast          (),

    .dma_axi_bvalid         (),
    .dma_axi_bready         (),
    .dma_axi_bresp          (),
    .dma_axi_bid            (),


    .dma_axi_arvalid        (),
    .dma_axi_arready        (),
    .dma_axi_arid           ('0),
    .dma_axi_araddr         (),
    .dma_axi_arsize         (),
    .dma_axi_arprot         (),
    .dma_axi_arlen          (),
    .dma_axi_arburst        (),

    .dma_axi_rvalid         (),
    .dma_axi_rready         (),
    .dma_axi_rid            (),
    .dma_axi_rdata          (),
    .dma_axi_rresp          (),
    .dma_axi_rlast          (),
`endif
    .timer_int              ( 1'b0 ),
    .extintsrc_req          ( 32'b0   ),

    .lsu_bus_clk_en         ( 1'b1  ),// Clock ratio b/w cpu core clk & AHB master interface
    .ifu_bus_clk_en         ( 1'b0  ),// Clock ratio b/w cpu core clk & AHB master interface
    .dbg_bus_clk_en         ( 1'b1  ),// Clock ratio b/w cpu core clk & AHB Debug master interface
    .dma_bus_clk_en         ( 1'b0  ),// Clock ratio b/w cpu core clk & AHB slave interface

    .trace_rv_i_insn_ip     (),
    .trace_rv_i_address_ip  (),
    .trace_rv_i_valid_ip    (),
    .trace_rv_i_exception_ip(),
    .trace_rv_i_ecause_ip   (),
    .trace_rv_i_interrupt_ip(),
    .trace_rv_i_tval_ip     (),

    .jtag_tck               ( io_in[0]  ),
    .jtag_tms               ( io_in[1]  ),
    .jtag_tdi               ( io_in[3]  ),
    .jtag_trst_n            ( io_in[2]  ),
    .jtag_tdo               ( io_in[4]  ),

    .mpc_debug_halt_ack     ( ),
    .mpc_debug_halt_req     ( 1'b0),
    .mpc_debug_run_ack      ( ),
    .mpc_debug_run_req      ( 1'b1),
    .mpc_reset_run_req      ( 1'b1),             // Start running after reset
     .debug_brkpt_status    ( ),

    .i_cpu_halt_req         ( 1'b0  ),    // Async halt req to CPU
    .o_cpu_halt_ack         (  ),    // core response to halt
    .o_cpu_halt_status      (  ), // 1'b1 indicates core is halted
    .i_cpu_run_req          ( 1'b0  ),     // Async restart req to CPU
    .o_debug_mode_status    (  ),
    .o_cpu_run_ack          (  ),     // Core response to run req

    .dec_tlu_perfcnt0       (),
    .dec_tlu_perfcnt1       (),
    .dec_tlu_perfcnt2       (),
    .dec_tlu_perfcnt3       (),

// remove mems DFT pins for opensource
    .dccm_ext_in_pkt        ( 48'b0),
    .iccm_ext_in_pkt        ( 48'b0),
    .ic_data_ext_in_pkt     ( 24'b0),
    .ic_tag_ext_in_pkt      ( 24'b0),

    .soft_int               ( 1'b0),
    .core_id                ( 28'b0),
    .scan_mode              ( 1'b0 ),         // To enable scan mode
    .mbist_mode             ( 1'b0 )        // to enable mbist

);


/*    counter #(
        .BITS(BITS)
    ) counter(
        .clk(clk),
        .reset(rst),
        .ready(wbs_ack_o),
        .valid(valid),
        .rdata(rdata),
        .wdata(wbs_dat_i),
        .wstrb(wstrb),
        .la_write(la_write),
        .la_input(la_data_in[63:32]),
        .count(count)
    );
*/
endmodule

/*module counter #(
    parameter BITS = 32
)(
    input clk,
    input reset,
    input valid,
    input [3:0] wstrb,
    input [BITS-1:0] wdata,
    input [BITS-1:0] la_write,
    input [BITS-1:0] la_input,
    output ready,
    output [BITS-1:0] rdata,
    output [BITS-1:0] count
);
    reg ready;
    reg [BITS-1:0] count;
    reg [BITS-1:0] rdata;

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            ready <= 0;
        end else begin
            ready <= 1'b0;
            if (~|la_write) begin
                count <= count + 1;
            end
            if (valid && !ready) begin
                ready <= 1'b1;
                rdata <= count;
                if (wstrb[0]) count[7:0]   <= wdata[7:0];
                if (wstrb[1]) count[15:8]  <= wdata[15:8];
                if (wstrb[2]) count[23:16] <= wdata[23:16];
                if (wstrb[3]) count[31:24] <= wdata[31:24];
            end else if (|la_write) begin
                count <= la_write & la_input;
            end
        end
    end

endmodule
*/
`default_nettype wire

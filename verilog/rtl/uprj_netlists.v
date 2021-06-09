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

// Include caravel global defines for the number of the user project IO pads 
`include "defines.v"
//`include "BrqRV_EB1/design/Defines/eb1_pdef.vh"
//`include "BrqRV_EB1/design/Defines/eb1_param.vh"
//`include "BrqRV_EB1/design/Defines/common_defines.vh"

`define USE_POWER_PINS

`ifdef GL
    // Assume default net type to be wire because GL netlists don't have the wire definitions
    `default_nettype wire
    `include "gl/user_project_wrapper.v"
    `include "gl/user_proj_example.v"
`else
    `include "BrqRV_EB1/design/Defines/eb1_pdef.vh"
    `include "BrqRV_EB1/design/Defines/eb1_param.vh" 
    `include "BrqRV_EB1/design/Defines/common_defines.vh"
    `include "user_project_wrapper.v"
    `include "user_proj_example.v"
    `include "BrqRV_EB1/design/eb1_brqrv_wrapper.sv"
    `include "BrqRV_EB1/design/eb1_mem.sv"
    `include "BrqRV_EB1/design/eb1_pic_ctrl.sv"
    `include "BrqRV_EB1/design/eb1_brqrv.sv"
    `include "BrqRV_EB1/design/eb1_dma_ctrl.sv"
    `include "BrqRV_EB1/design/ifu/eb1_ifu_aln_ctl.sv"
    `include "BrqRV_EB1/design/ifu/eb1_ifu_compress_ctl.sv"
    `include "BrqRV_EB1/design/ifu/eb1_ifu_ifc_ctl.sv"
    `include "BrqRV_EB1/design/ifu/eb1_ifu_bp_ctl.sv"
    `include "BrqRV_EB1/design/ifu/eb1_ifu_ic_mem.sv"
    `include "BrqRV_EB1/design/ifu/eb1_ifu_mem_ctl.sv"
    `include "BrqRV_EB1/design/ifu/eb1_ifu_iccm_mem.sv"
    `include "BrqRV_EB1/design/ifu/eb1_ifu.sv"
    `include "BrqRV_EB1/design/dec/eb1_dec_decode_ctl.sv"
    `include "BrqRV_EB1/design/dec/eb1_dec_gpr_ctl.sv"
    `include "BrqRV_EB1/design/dec/eb1_dec_ib_ctl.sv"
    `include "BrqRV_EB1/design/dec/eb1_dec_tlu_ctl.sv"
    `include "BrqRV_EB1/design/dec/eb1_dec_trigger.sv"
    `include "BrqRV_EB1/design/dec/eb1_dec.sv"
    `include "BrqRV_EB1/design/exu/eb1_exu_alu_ctl.sv"
    `include "BrqRV_EB1/design/exu/eb1_exu_mul_ctl.sv"
    `include "BrqRV_EB1/design/exu/eb1_exu_div_ctl.sv"
    `include "BrqRV_EB1/design/exu/eb1_exu.sv"
    `include "BrqRV_EB1/design/lsu/eb1_lsu.sv"
    `include "BrqRV_EB1/design/lsu/eb1_lsu_clkdomain.sv"
    `include "BrqRV_EB1/design/lsu/eb1_lsu_addrcheck.sv"
    `include "BrqRV_EB1/design/lsu/eb1_lsu_lsc_ctl.sv"
    `include "BrqRV_EB1/design/lsu/eb1_lsu_stbuf.sv"
    `include "BrqRV_EB1/design/lsu/eb1_lsu_bus_buffer.sv"
    `include "BrqRV_EB1/design/lsu/eb1_lsu_bus_intf.sv"
    `include "BrqRV_EB1/design/lsu/eb1_lsu_ecc.sv"
    `include "BrqRV_EB1/design/lsu/eb1_lsu_dccm_mem.sv"
    `include "BrqRV_EB1/design/lsu/eb1_lsu_dccm_ctl.sv"
    `include "BrqRV_EB1/design/lsu/eb1_lsu_trigger.sv"
    `include "BrqRV_EB1/design/dbg/eb1_dbg.sv"
    `include "BrqRV_EB1/design/dmi/dmi_wrapper.v"
    `include "BrqRV_EB1/design/dmi/dmi_jtag_to_core_sync.v"
    `include "BrqRV_EB1/design/dmi/rvjtag_tap.v"
    `include "BrqRV_EB1/design/soc_files/uart_rx_prog.v"
    `include "BrqRV_EB1/design/soc_files/iccm_controller.v"
    `include "BrqRV_EB1/design/sky130_sram_1kbyte_1rw1r_32x256_8.v"
    `include "BrqRV_EB1/design/lib/eb1_lib.sv"
    `include "BrqRV_EB1/design/lib/beh_lib.sv"
    `include "BrqRV_EB1/design/lib/mem_lib.sv"
    `include "BrqRV_EB1/design/lib"
`endif

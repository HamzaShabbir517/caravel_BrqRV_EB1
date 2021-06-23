# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

source $script_dir/../../caravel/openlane/user_project_wrapper_empty/fixed_wrapper_cfgs.tcl

set ::env(DESIGN_NAME) user_project_wrapper
#section end

# User Configurations

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$script_dir/../../caravel/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/user_project_wrapper.v \
	$script_dir/../../verilog/rtl/user_proj_example.v \
  	$script_dir/../../verilog/rtl/BrqRV_EB1/BrqRV_EB1.v "
#blackbox setup
set ::env(VERILOG_FILES_BLACKBOX) "\
	$script_dir/../../caravel/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/BrqRV_EB1/sky130_sram_1kbyte_1rw1r_32x256_8.v "
set ::env(EXTRA_LEFS) $PDK_ROOT/sky130A/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef
set ::env(EXTRA_GDS_FILES) $PDK_ROOT/sky130A/libs.ref/sky130_sram_macros/gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds

set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_PERIOD) "40"

set ::env(GLB_RT_ALLOW_CONGESTION) 1
set ::env(GLB_RT_MAXLAYER) 5
set ::env(GLB_RT_MINLAYER) 2
set ::env(GLB_RT_ADJUSTMENT) 0.45
set ::env(GENERATE_FINAL_SUMMARY_REPORT) 1
set ::env(SYNTH_READ_BLACKBOX_LIB) 1
set ::env(SYNTH_STRATEGY) "DELAY 0" 

#pin order and pdn path
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg
set ::env(PDN_CFG) $script_dir/common_pdn.tcl







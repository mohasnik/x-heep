# Copyright 2022 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# Define design macros

set design_name xilinx_cips

# Create block design
create_bd_design $design_name

# Create CIPS instance (minimal config: PL clock + reset only)
create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips versal_cips_0

set_property -dict [list \
  CONFIG.PS_PMC_CONFIG { \
    CLOCK_MODE {Custom} \
    PS_NUM_FABRIC_RESETS {1} \
    PS_USE_PMCPL_CLK0 {1} \
    PS_PL_CLK0_BUF {1} \
    PS_USE_PMCPL_CLK1 {0} \
    PS_USE_PMCPL_CLK2 {0} \
    PS_USE_PMCPL_CLK3 {0} \
    PMC_CRP_PL0_REF_CTRL_FREQMHZ {100} \
  } \
] [get_bd_cells versal_cips_0]

# Create output ports matching the clk_wizard wrapper interface
create_bd_port -dir O -type clk clk_out1_0
create_bd_port -dir O -type rst pl0_resetn

# Connect CIPS outputs to ports
connect_bd_net [get_bd_pins versal_cips_0/pl0_ref_clk] [get_bd_ports clk_out1_0]
connect_bd_net [get_bd_pins versal_cips_0/pl0_resetn]  [get_bd_ports pl0_resetn]

# Save and close block design
save_bd_design
close_bd_design $design_name

# Create wrapper
set wrapper_path [ make_wrapper -fileset sources_1 -files [ get_files -norecurse xilinx_cips.bd ] -top ]
add_files -norecurse -fileset sources_1 $wrapper_path
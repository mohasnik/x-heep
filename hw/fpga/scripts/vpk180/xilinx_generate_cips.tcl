# Copyright 2026 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# Define design macros

set design_name xilinx_cips

# Create block design
create_bd_design $design_name

# Create CIPS instance
create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips versal_cips_0

# Apply VPK180 Board Presets and Essential Configurations
# Even for PL-only designs (Option B), CIPS must initialize the board's PMC and MIOs
set_property -dict [list \
  CONFIG.PS_PMC_CONFIG { \
    CLOCK_MODE {Custom} \
    PS_NUM_FABRIC_RESETS {1} \
    PS_USE_PMCPL_CLK0 {1} \
    PS_PL_CLK0_BUF {1} \
    PMC_CRP_PL0_REF_CTRL_FREQMHZ {100} \
    # Enable PMC UART (hardwired to USB-UART bridge on VPK180)
    # This allows monitoring the board even if PL UART is not yet configured
    PMC_USE_UART0 {1} \
    PMC_UART0_PERIPHERAL_ENABLE {1} \
    PMC_UART0_PERIPHERAL_IO {PMC_MIO 42 .. 43} \
    # Disable unused AXI interfaces to save area
    PS_USE_M_AXI_FPD {0} \
    PS_USE_S_AXI_FPD {0} \
    # Ensure PMC-MIO voltages are correct for VPK180 (1.8V)
    PMC_MIO_37_DIRECTION {out} \
    PMC_MIO_37_SCHMITT {1} \
  } \
] [get_bd_cells versal_cips_0]

# Create output ports matching the wrapper interface
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
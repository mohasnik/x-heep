# Copyright 2022 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# Define design macros

set design_name      xilinx_clk_wizard

set_property board_part xilinx.com:vpk180:part0:1.2 [current_project]

# Create block design
create_bd_design $design_name

# Create instance and set properties

set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard:1.0 clk_wizard_0 ]
set_property CONFIG.CLK_IN1_BOARD_INTERFACE {lpddr4_clk1} [get_bd_cells clk_wizard_0]


make_bd_pins_external $clk_wiz_0
make_bd_intf_pins_external $clk_wiz_0

# Save and close block design
save_bd_design
close_bd_design $design_name

# create wrapper
set wrapper_path [ make_wrapper -fileset sources_1 -files [ get_files -norecurse xilinx_clk_wizard.bd ] -top ]
add_files -norecurse -fileset sources_1 $wrapper_path

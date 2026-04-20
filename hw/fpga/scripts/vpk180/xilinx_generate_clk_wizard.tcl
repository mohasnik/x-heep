# Copyright 2022 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# Define design macros

set design_name      xilinx_clk_wizard
set in_clk_freq_MHz  100
set out_clk_freq_MHz 50


# Create block design
create_bd_design $design_name

# Create ports
set clk_100MHz [ create_bd_port -dir I -type clk -freq_hz [ expr $in_clk_freq_MHz * 1000000 ] clk_100MHz ]
set clk_out1_0 [ create_bd_port -dir O -type clk clk_out1_0 ]
set_property -dict [ list CONFIG.FREQ_HZ [ expr $out_clk_freq_MHz * 1000000 ] ] $clk_out1_0

# Create instance and set properties

set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard:1.0 clk_wizard_0 ]
set_property -dict [list \
  CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
  CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
  CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
  CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
  CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
  CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
  CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {50,100.000,100.000,100.000,100.000,100.000,100.000} \
  CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
  CONFIG.CLKOUT_USED {true,false,false,false,false,false,false} \
  CONFIG.PRIMITIVE_TYPE {Auto} \
  CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
] $clk_wiz_0

# Create port connections
connect_bd_net -net clk_in1_0_1 [ get_bd_ports clk_100MHz ] [ get_bd_pins clk_wizard_0/clk_in1 ]
connect_bd_net -net clk_wiz_0_clk_out1 [ get_bd_ports clk_out1_0 ] [ get_bd_pins clk_wizard_0/clk_out1 ]

# Save and close block design
save_bd_design
close_bd_design $design_name

# create wrapper
set wrapper_path [ make_wrapper -fileset sources_1 -files [ get_files -norecurse xilinx_clk_wizard.bd ] -top ]
add_files -norecurse -fileset sources_1 $wrapper_path

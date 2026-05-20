# Copyright 2026 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# VPK180 timing constraints for the PS-enabled flow.

# The PL clock wizard and NoC IP XDCs create clocks for their LPDDR4 inputs.

# The SPI slave debug port remains an external clock domain even when PS_ENABLE=1.
create_clock -add -name spi_slave_clk_pin -period 16.000 -waveform {0.000 8.000} \
  [get_ports {spi_slave_sck_io}]


# Treat JTAG TAP clocking as asynchronous to the main X-HEEP system clock.
# Reuse the clock objects created by the Xilinx IP XDCs instead of creating
# duplicate clocks on fragile post-synthesis hierarchy names.
set xheep_system_clks [get_clocks -quiet -include_generated_clocks -of_objects \
  [get_ports -quiet {lpddr4_clk3_clk_p}]]

set xheep_jtag_clks [get_clocks -quiet {
  clkout1_primitive
  xilinx_ps_wizard_wrapper_i/xilinx_ps_wizard_i/axi_jtag/inst/u_jtag_proc/tck_i_reg/Q
}]

set_clock_groups -asynchronous \
  -group $xheep_system_clks \
  -group $xheep_jtag_clks



# False paths
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *dmcontrol_q_reg[ndmreset]}]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *synch_regs_q_reg[3]}]

# Copyright 2026 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# VPK180 timing constraints for the PS-enabled flow.

# LPDDR4_CLK1 is the external board clock feeding the PL clock wizard.
if {[llength [get_ports -quiet {lpddr4_clk1_clk_p}]] && \
    [llength [get_clocks -quiet -of_objects [get_ports {lpddr4_clk1_clk_p}]]] == 0} {
  create_clock -period 5.000 -name lpddr4_clk1 -waveform {0.000 2.500} \
    [get_ports {lpddr4_clk1_clk_p}]
}

# The SPI slave debug port remains an external clock domain even when PS_ENABLE=1.
if {[llength [get_ports -quiet {spi_slave_sck_io}]] && \
    [llength [get_clocks -quiet -of_objects [get_ports {spi_slave_sck_io}]]] == 0} {
  create_clock -add -name spi_slave_clk_pin -period 16.000 -waveform {0.000 8.000} \
    [get_ports {spi_slave_sck_io}]
}

# False paths
# set_false_path -from [get_cells -hierarchical -filter {NAME =~ *dmcontrol_q_reg[ndmreset]}]
# set_false_path -from [get_cells -hierarchical -filter {NAME =~ *synch_regs_q_reg[3]}]

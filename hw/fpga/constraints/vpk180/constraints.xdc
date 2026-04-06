# Copyright 2026 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# JTAG Clock
create_clock -add -name jtag_clk_pin -period 100.00 -waveform {0 50} [get_ports {jtag_tck_i}];

# SPI Slave Clock
create_clock -add -name spi_slave_clk_pin -period 16.00 -waveform {0 8} [get_ports {spi_slave_sck_io}];

# False paths
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *dmcontrol_q_reg[ndmreset]}]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *synch_regs_q_reg[3]}]

# Copyright 2026 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# VPK180 timing constraints for the PS-enabled flow.

# LPDDR4_CLK1 is the external board clock feeding the PL clock wizard.
create_clock -period 5.000 -name lpddr4_clk1 -waveform {0.000 2.500} \
  [get_ports {lpddr4_clk1_clk_p}]

# The SPI slave debug port remains an external clock domain even when PS_ENABLE=1.
create_clock -add -name spi_slave_clk_pin -period 16.000 -waveform {0.000 8.000} \
  [get_ports {spi_slave_sck_io}]


# AXI JTAG TCK used by the X-HEEP debug TAP.
# AXI JTAG generates TCK from its AXI clock; the IP XDC uses divide_by 8 too.
create_generated_clock -name xheep_jtag_tck \
  -source [get_pins -hierarchical {xilinx_ps_wizard_wrapper_i/xilinx_ps_wizard_i/axi_jtag/inst/u_jtag_proc/tck_i_reg/C}] \
  -divide_by 8 \
  [get_pins -hierarchical {x_heep_system_i/core_v_mini_mcu_i/debug_subsystem_i/dmi_jtag_i/i_dmi_jtag_tap/tck_i}]

# Functional TDO clock is the inverted TCK after the DFT TCK mux.
create_generated_clock -name xheep_jtag_tck_n \
  -source [get_pins -hierarchical {xilinx_ps_wizard_wrapper_i/xilinx_ps_wizard_i/axi_jtag/inst/u_jtag_proc/tck_i_reg/C}] \
  -divide_by 8 \
  -invert \
  [get_pins -hierarchical {x_heep_system_i/core_v_mini_mcu_i/debug_subsystem_i/dmi_jtag_i/i_dmi_jtag_tap/i_dft_tck_mux/xilinx_i_clk_mux2_i/i_BUFGMUX/O}]

# Treat JTAG TAP clocking as asynchronous to the main X-HEEP system clock.
set_clock_groups -asynchronous \
  -group [get_clocks -of_objects [get_pins -hierarchical {x_heep_system_i/clk_i}]] \
  -group [get_clocks {xheep_jtag_tck xheep_jtag_tck_n}]


# False paths
# set_false_path -from [get_cells -hierarchical -filter {NAME =~ *dmcontrol_q_reg[ndmreset]}]
# set_false_path -from [get_cells -hierarchical -filter {NAME =~ *synch_regs_q_reg[3]}]

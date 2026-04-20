# Copyright 2026 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# SPI Slave Clock
# This port remains external even with PS_ENABLE=1
create_clock -add -name spi_slave_clk_pin -period 16.00 -waveform {0 8} [get_ports {spi_slave_sck_io}];

# False paths for cross-clock domain synchronization
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *dmcontrol_q_reg[ndmreset]}]
set_false_path -from [get_cells -hierarchical -filter {NAME =~ *synch_regs_q_reg[3]}]
set_property -dict {PACKAGE_PIN BE31 IOSTANDARD LVCMOS18} [get_ports exit_value_o]

# # PERIPHERALS (I2C, GPIO)
# These remain as top-level ports in the wrapper even with PS_ENABLE=1.
set_property -dict {PACKAGE_PIN BH33 IOSTANDARD LVCMOS18} [get_ports i2c_scl_io]
set_property -dict {PACKAGE_PIN BJ33 IOSTANDARD LVCMOS18} [get_ports i2c_sda_io]

# Mapping GPIOs to FMC+ LA pins (Standard VPK180 usage)
set_property -dict {PACKAGE_PIN AP32 IOSTANDARD LVCMOS18} [get_ports {gpio_io[0]}]
set_property -dict {PACKAGE_PIN AP33 IOSTANDARD LVCMOS18} [get_ports {gpio_io[1]}]
set_property -dict {PACKAGE_PIN AR32 IOSTANDARD LVCMOS18} [get_ports {gpio_io[2]}]
set_property -dict {PACKAGE_PIN AR33 IOSTANDARD LVCMOS18} [get_ports {gpio_io[3]}]
set_property -dict {PACKAGE_PIN AT32 IOSTANDARD LVCMOS18} [get_ports {gpio_io[4]}]
set_property -dict {PACKAGE_PIN AT33 IOSTANDARD LVCMOS18} [get_ports {gpio_io[5]}]
set_property -dict {PACKAGE_PIN AU32 IOSTANDARD LVCMOS18} [get_ports {gpio_io[6]}]
set_property -dict {PACKAGE_PIN AU33 IOSTANDARD LVCMOS18} [get_ports {gpio_io[7]}]
set_property -dict {PACKAGE_PIN AV32 IOSTANDARD LVCMOS18} [get_ports {gpio_io[8]}]
set_property -dict {PACKAGE_PIN AV33 IOSTANDARD LVCMOS18} [get_ports {gpio_io[9]}]
set_property -dict {PACKAGE_PIN AW32 IOSTANDARD LVCMOS18} [get_ports {gpio_io[10]}]
set_property -dict {PACKAGE_PIN AW33 IOSTANDARD LVCMOS18} [get_ports {gpio_io[11]}]
set_property -dict {PACKAGE_PIN AY32 IOSTANDARD LVCMOS18} [get_ports {gpio_io[12]}]
set_property -dict {PACKAGE_PIN AY33 IOSTANDARD LVCMOS18} [get_ports {gpio_io[13]}]

# # Note: UART, JTAG, and Boot Switches are routed internally to the PS/CIPS.
# Physical pin mapping for these is handled by CIPS MIO configuration
# or is not applicable for the virtualized PL interfaces.

# -----------------------------------------------------------------------------
# AXI Quad SPI (PL-side) — exposes the ps_wizard SPI_0 to board pins so the
# wizard-generated IOBUFs have a destination and DRC passes. Placeholder pins
# from the same FMC+ LA bank family as the GPIOs above; replace with the real
# target pins from VPK180 UG1366 once the physical destination is known.
# -----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN BA32 IOSTANDARD LVCMOS18} [get_ports {ps_quadspi_io_io0_io}]
set_property -dict {PACKAGE_PIN BA33 IOSTANDARD LVCMOS18} [get_ports {ps_quadspi_io_io1_io}]
set_property -dict {PACKAGE_PIN BB32 IOSTANDARD LVCMOS18} [get_ports {ps_quadspi_io_io2_io}]
set_property -dict {PACKAGE_PIN BB33 IOSTANDARD LVCMOS18} [get_ports {ps_quadspi_io_io3_io}]
set_property -dict {PACKAGE_PIN BC32 IOSTANDARD LVCMOS18} [get_ports {ps_quadspi_io_sck_io}]
set_property -dict {PACKAGE_PIN BC33 IOSTANDARD LVCMOS18} [get_ports {ps_quadspi_io_ss_io[0]}]

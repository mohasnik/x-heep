# Copyright 2026 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# # CLOCK
# Clock is provided by CIPS internally, no external clock ports needed in XDC.

# # RESET
# Reset is provided by CIPS (pl0_resetn), no external reset pin needed.

# # LEDS
# Using PL_GPIO_LEDs from VPK180 (Bank 701, 1.5V/1.8V depending on board config, typically 1.8V for these pins)
set_property -dict {PACKAGE_PIN BC30 IOSTANDARD LVCMOS18} [get_ports rst_led_o]
set_property -dict {PACKAGE_PIN BC31 IOSTANDARD LVCMOS18} [get_ports clk_led_o]
set_property -dict {PACKAGE_PIN BD31 IOSTANDARD LVCMOS18} [get_ports exit_valid_o]
set_property -dict {PACKAGE_PIN BE31 IOSTANDARD LVCMOS18} [get_ports exit_value_o]

# # SWITCHES
# VPK180 User DIP Switches (SW10, SW11) - Mapping to available pins
# Using pins from Bank 701/702 if available or placeholder
set_property -dict {PACKAGE_PIN BB32 IOSTANDARD LVCMOS18} [get_ports execute_from_flash_i]
set_property -dict {PACKAGE_PIN BB33 IOSTANDARD LVCMOS18} [get_ports boot_select_i]

# # UART (Routed to FTDI USB-to-UART bridge, PL_UART)
set_property -dict {PACKAGE_PIN BE30 IOSTANDARD LVCMOS18} [get_ports uart_tx_o]
set_property -dict {PACKAGE_PIN BF30 IOSTANDARD LVCMOS18} [get_ports uart_rx_i]

# # JTAG (Mapping to PL JTAG pins if used, otherwise CIPS handles JTAG)
# These are often routed to the FMC or header. Using PL_JTAG placeholder pins for VPK180.
set_property -dict {PACKAGE_PIN BF32 IOSTANDARD LVCMOS18} [get_ports jtag_tdi_i]
set_property -dict {PACKAGE_PIN BF33 IOSTANDARD LVCMOS18} [get_ports jtag_tdo_o]
set_property -dict {PACKAGE_PIN BG32 IOSTANDARD LVCMOS18} [get_ports jtag_tms_i]
set_property -dict {PACKAGE_PIN BG33 IOSTANDARD LVCMOS18} [get_ports jtag_tck_i]
set_property -dict {PACKAGE_PIN BH32 IOSTANDARD LVCMOS18} [get_ports jtag_trst_ni]

# # I2C (PMC_I2C is usually used, but if PL I2C is needed)
set_property -dict {PACKAGE_PIN BH33 IOSTANDARD LVCMOS18} [get_ports i2c_scl_io]
set_property -dict {PACKAGE_PIN BJ33 IOSTANDARD LVCMOS18} [get_ports i2c_sda_io]

# SPI SD / GPIOs / etc. would typically go to the FMC connector on VPK180.
# Mapping these to FMC+ LA pins as single-ended 1.8V.
# Example mapping for VPK180 FMCP+ (J302) LA pins:
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

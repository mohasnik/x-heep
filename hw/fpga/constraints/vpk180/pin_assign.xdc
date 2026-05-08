# Copyright 2026 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# VPK180 pin plan for the PS-enabled flow.
# - Use the real LPDDR4_CLK1 pins from AMD's VPK180 master XDC.
# - Route all PL-side user I/O to the FMCP1 LA bank so the design can be wired
#   out through the FMC+ connector without touching board-management nets.
# - FMCP1 LA banks on VPK180 use VADJ_FMC, so the matching I/O standard from the
#   master XDC is LVCMOS15.

# -----------------------------------------------------------------------------
# LPDDR4 clock used as external PL reference
# Master XDC:
#   LPDDR4_CLK1_P -> BK6
#   LPDDR4_CLK1_N -> BK5
# -----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN BK6 IOSTANDARD DIFF_LVSTL_11} [get_ports {lpddr4_clk1_clk_p}]
set_property -dict {PACKAGE_PIN BK5 IOSTANDARD DIFF_LVSTL_11} [get_ports {lpddr4_clk1_clk_n}]

# -----------------------------------------------------------------------------
# Status, low-speed I/O, and shared wrapper ports
# -----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN BV49 IOSTANDARD LVCMOS15} [get_ports {rst_i}]        ; # FMCP1_LA00_CC_P
set_property -dict {PACKAGE_PIN BV50 IOSTANDARD LVCMOS15} [get_ports {rst_led_o}]    ; # FMCP1_LA00_CC_N
set_property -dict {PACKAGE_PIN BW51 IOSTANDARD LVCMOS15} [get_ports {clk_led_o}]    ; # FMCP1_LA01_CC_P
set_property -dict {PACKAGE_PIN BW52 IOSTANDARD LVCMOS15} [get_ports {exit_valid_o}] ; # FMCP1_LA01_CC_N
set_property -dict {PACKAGE_PIN CB46 IOSTANDARD LVCMOS15} [get_ports {exit_value_o}] ; # FMCP1_LA02_P

set_property -dict {PACKAGE_PIN CC47 IOSTANDARD LVCMOS15} [get_ports {i2c_scl_io}]     ; # FMCP1_LA02_N
set_property -dict {PACKAGE_PIN CD47 IOSTANDARD LVCMOS15} [get_ports {i2c_sda_io}]     ; # FMCP1_LA03_P
set_property -dict {PACKAGE_PIN CD48 IOSTANDARD LVCMOS15} [get_ports {pdm2pcm_clk_io}] ; # FMCP1_LA03_N
set_property -dict {PACKAGE_PIN CA49 IOSTANDARD LVCMOS15} [get_ports {pdm2pcm_pdm_io}] ; # FMCP1_LA04_P
set_property -dict {PACKAGE_PIN CB50 IOSTANDARD LVCMOS15} [get_ports {i2s_sck_io}]     ; # FMCP1_LA04_N
set_property -dict {PACKAGE_PIN CC43 IOSTANDARD LVCMOS15} [get_ports {i2s_ws_io}]      ; # FMCP1_LA05_P
set_property -dict {PACKAGE_PIN CB44 IOSTANDARD LVCMOS15} [get_ports {i2s_sd_io}]      ; # FMCP1_LA05_N

# -----------------------------------------------------------------------------
# GPIO bank
# -----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN CA44 IOSTANDARD LVCMOS15} [get_ports {gpio_io[0]}]   ; # FMCP1_LA06_P
set_property -dict {PACKAGE_PIN CB45 IOSTANDARD LVCMOS15} [get_ports {gpio_io[1]}]   ; # FMCP1_LA06_N
set_property -dict {PACKAGE_PIN CB49 IOSTANDARD LVCMOS15} [get_ports {gpio_io[2]}]   ; # FMCP1_LA07_P
set_property -dict {PACKAGE_PIN CC50 IOSTANDARD LVCMOS15} [get_ports {gpio_io[3]}]   ; # FMCP1_LA07_N
set_property -dict {PACKAGE_PIN BY49 IOSTANDARD LVCMOS15} [get_ports {gpio_io[4]}]   ; # FMCP1_LA08_P
set_property -dict {PACKAGE_PIN BY50 IOSTANDARD LVCMOS15} [get_ports {gpio_io[5]}]   ; # FMCP1_LA08_N
set_property -dict {PACKAGE_PIN CC45 IOSTANDARD LVCMOS15} [get_ports {gpio_io[6]}]   ; # FMCP1_LA09_P
set_property -dict {PACKAGE_PIN CD46 IOSTANDARD LVCMOS15} [get_ports {gpio_io[7]}]   ; # FMCP1_LA09_N
set_property -dict {PACKAGE_PIN CC44 IOSTANDARD LVCMOS15} [get_ports {gpio_io[8]}]   ; # FMCP1_LA10_P
set_property -dict {PACKAGE_PIN CD45 IOSTANDARD LVCMOS15} [get_ports {gpio_io[9]}]   ; # FMCP1_LA10_N
set_property -dict {PACKAGE_PIN CB51 IOSTANDARD LVCMOS15} [get_ports {gpio_io[10]}]  ; # FMCP1_LA11_P
set_property -dict {PACKAGE_PIN CC52 IOSTANDARD LVCMOS15} [get_ports {gpio_io[11]}]  ; # FMCP1_LA11_N
set_property -dict {PACKAGE_PIN BW49 IOSTANDARD LVCMOS15} [get_ports {gpio_io[12]}]  ; # FMCP1_LA12_P
set_property -dict {PACKAGE_PIN BW50 IOSTANDARD LVCMOS15} [get_ports {gpio_io[13]}]  ; # FMCP1_LA12_N

# -----------------------------------------------------------------------------
# SPI master from x-heep_system
# -----------------------------------------------------------------------------
# set_property -dict {PACKAGE_PIN CC49 IOSTANDARD LVCMOS15} [get_ports {spi_sd_io[0]}] ; # FMCP1_LA13_P
# set_property -dict {PACKAGE_PIN CD50 IOSTANDARD LVCMOS15} [get_ports {spi_sd_io[1]}] ; # FMCP1_LA13_N
# set_property -dict {PACKAGE_PIN BY51 IOSTANDARD LVCMOS15} [get_ports {spi_sd_io[2]}] ; # FMCP1_LA14_P
# set_property -dict {PACKAGE_PIN CA52 IOSTANDARD LVCMOS15} [get_ports {spi_sd_io[3]}] ; # FMCP1_LA14_N
# set_property -dict {PACKAGE_PIN CD51 IOSTANDARD LVCMOS15} [get_ports {spi_csb_o}]     ; # FMCP1_LA15_P
# set_property -dict {PACKAGE_PIN CD52 IOSTANDARD LVCMOS15} [get_ports {spi_sck_o}]     ; # FMCP1_LA15_N

# -----------------------------------------------------------------------------
# SPI slave/debug port
# Use clock-capable FMC LA pins for the externally-driven clock domain.
# -----------------------------------------------------------------------------
# set_property -dict {PACKAGE_PIN BU41 IOSTANDARD LVCMOS15} [get_ports {spi_slave_sck_io}]  ; # FMCP1_LA17_CC_P
# set_property -dict {PACKAGE_PIN BU42 IOSTANDARD LVCMOS15} [get_ports {spi_slave_cs_io}]   ; # FMCP1_LA17_CC_N
# set_property -dict {PACKAGE_PIN BW39 IOSTANDARD LVCMOS15} [get_ports {spi_slave_mosi_io}] ; # FMCP1_LA18_CC_P
# set_property -dict {PACKAGE_PIN BY39 IOSTANDARD LVCMOS15} [get_ports {spi_slave_miso_io}] ; # FMCP1_LA18_CC_N

# -----------------------------------------------------------------------------
# SPI2
# -----------------------------------------------------------------------------
# set_property -dict {PACKAGE_PIN CA51 IOSTANDARD LVCMOS15} [get_ports {spi2_sd_io[0]}]  ; # FMCP1_LA16_P
# set_property -dict {PACKAGE_PIN CB52 IOSTANDARD LVCMOS15} [get_ports {spi2_sd_io[1]}]  ; # FMCP1_LA16_N
# set_property -dict {PACKAGE_PIN BN40 IOSTANDARD LVCMOS15} [get_ports {spi2_sd_io[2]}]  ; # FMCP1_LA19_P
# set_property -dict {PACKAGE_PIN BP40 IOSTANDARD LVCMOS15} [get_ports {spi2_sd_io[3]}]  ; # FMCP1_LA19_N
# set_property -dict {PACKAGE_PIN BR42 IOSTANDARD LVCMOS15} [get_ports {spi2_csb_o[0]}]  ; # FMCP1_LA20_P
# set_property -dict {PACKAGE_PIN BT41 IOSTANDARD LVCMOS15} [get_ports {spi2_csb_o[1]}]  ; # FMCP1_LA20_N
# set_property -dict {PACKAGE_PIN CD40 IOSTANDARD LVCMOS15} [get_ports {spi2_sck_o}]      ; # FMCP1_LA21_P

# -----------------------------------------------------------------------------
# Shared external flash pins used by x-heep_system and then muxed against PS
# QuadSPI by the ECO hook.
# -----------------------------------------------------------------------------
# set_property -dict {PACKAGE_PIN CD41 IOSTANDARD LVCMOS15} [get_ports {spi_flash_sd_io[0]}] ; # FMCP1_LA21_N
# set_property -dict {PACKAGE_PIN CD42 IOSTANDARD LVCMOS15} [get_ports {spi_flash_sd_io[1]}] ; # FMCP1_LA22_P
# set_property -dict {PACKAGE_PIN CD43 IOSTANDARD LVCMOS15} [get_ports {spi_flash_sd_io[2]}] ; # FMCP1_LA22_N
# set_property -dict {PACKAGE_PIN CB40 IOSTANDARD LVCMOS15} [get_ports {spi_flash_sd_io[3]}] ; # FMCP1_LA23_P
# set_property -dict {PACKAGE_PIN CC40 IOSTANDARD LVCMOS15} [get_ports {spi_flash_csb_o}]     ; # FMCP1_LA23_N
# set_property -dict {PACKAGE_PIN BY40 IOSTANDARD LVCMOS15} [get_ports {spi_flash_sck_o}]     ; # FMCP1_LA24_P

# -----------------------------------------------------------------------------
# PS QuadSPI parking pins
# In the PS-enabled VPK180 flow these ports need real LOCs so the
# wizard-generated top-level IOBUFs are placeable before the ECO SPI-flash mux
# removes them from the final routed interface.
# -----------------------------------------------------------------------------
# set_property -dict {PACKAGE_PIN CA39 IOSTANDARD LVCMOS15} [get_ports {ps_quadspi_io_io0_io}]    ; # FMCP1_LA24_N
# set_property -dict {PACKAGE_PIN CC38 IOSTANDARD LVCMOS15} [get_ports {ps_quadspi_io_io1_io}]    ; # FMCP1_LA25_P
# set_property -dict {PACKAGE_PIN CC39 IOSTANDARD LVCMOS15} [get_ports {ps_quadspi_io_io2_io}]    ; # FMCP1_LA25_N
# set_property -dict {PACKAGE_PIN CB41 IOSTANDARD LVCMOS15} [get_ports {ps_quadspi_io_io3_io}]    ; # FMCP1_LA26_P
# set_property -dict {PACKAGE_PIN CC42 IOSTANDARD LVCMOS15} [get_ports {ps_quadspi_io_sck_io}]    ; # FMCP1_LA26_N
# set_property -dict {PACKAGE_PIN CA38 IOSTANDARD LVCMOS15} [get_ports {ps_quadspi_io_ss_io[0]}]  ; # FMCP1_LA27_P

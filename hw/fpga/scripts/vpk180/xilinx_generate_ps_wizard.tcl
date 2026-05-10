# Copyright 2026 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# File: xilinx_generate_ps_wizard.tcl
# Author: Mohammadhossein Nikkhahghomi
# Date: 06/04/2026
#

set design_name xilinx_ps_wizard
create_bd_design $design_name
current_bd_design $design_name
current_bd_instance /

# -----------------------------------------------------------------------------
# External PL-facing ports for the SV wrapper
# -----------------------------------------------------------------------------

set ps_quadspi_io [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 ps_quadspi_io]

# UART intentionally not exported in this script yet.
# Native CIPS UART-through-EMIO should be added once the exact Vivado-generated
# CIPS property string is captured from the GUI for this Vivado/CIPS version.

set ps_tdi_o  [create_bd_port -dir O ps_tdi_o]
set ps_tms_o  [create_bd_port -dir O ps_tms_o]
set ps_tck_o  [create_bd_port -dir O ps_tck_o]
set ps_tdo_i  [create_bd_port -dir I ps_tdo_i]
set ps_gpio_i [create_bd_port -dir I -from 1 -to 0 ps_gpio_i]
set ps_gpio_o [create_bd_port -dir O -from 4 -to 0 ps_gpio_o]

# -----------------------------------------------------------------------------
# CIPS
# -----------------------------------------------------------------------------

set versal_cips_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips versal_cips_0]

# Full System mode so M_AXI_FPD / IRQs / PL clocks-resets are available
set_property CONFIG.DESIGN_MODE {1} $versal_cips_0

# NOTE:
# - We intentionally keep DDR disabled here.
# - For VPK180 onboard LPDDR4, use proper CIPS/board/block automation later,
#   not manual generic DDR4/NoC construction.
# - UART is NOT configured here yet, because the exact EMIO Tcl token should
#   be taken from Vivado-generated CIPS Tcl for this version.

set_property -dict [list \
  CONFIG.IO_CONFIG_MODE {Custom} \
  CONFIG.PS_PMC_CONFIG { \
    BOOT_MODE {Custom} \
    CLOCK_MODE {Custom} \
    IO_CONFIG_MODE {Custom} \
    PMC_CRP_PL0_REF_CTRL_FREQMHZ {100} \
    PMC_CRP_PL1_REF_CTRL_FREQMHZ {100} \
    PMC_SD1_PERIPHERAL {{CLK_100_SDR_OTAP_DLY 0x00} {CLK_200_SDR_OTAP_DLY 0x00} {CLK_50_DDR_ITAP_DLY 0x00} {CLK_50_DDR_OTAP_DLY 0x00} {CLK_50_SDR_ITAP_DLY 0x2C} {CLK_50_SDR_OTAP_DLY 0x4} {ENABLE 1} {IO {PMC_MIO 26 .. 36}}} \
    PS_IRQ_USAGE {{CH0 1} {CH1 0} {CH10 0} {CH11 0} {CH12 0} {CH13 0} {CH14 0} {CH15 0} {CH2 0} {CH3 0} {CH4 0} {CH5 0} {CH6 0} {CH7 0} {CH8 0} {CH9 0}} \
    PS_M_AXI_FPD_DATA_WIDTH {32} \
    PS_NUM_FABRIC_RESETS {1} \
    PS_PL_CONNECTIVITY_MODE {Custom} \
    PS_UART0_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 42 .. 43}}} \
    PS_USE_FPD_AXI_NOC0 {0} \
    PS_USE_M_AXI_FPD {1} \
    PS_USE_PMCPL_CLK0 {1} \
    PS_USE_PMCPL_CLK1 {1} \
    PS_USE_PMCPL_CLK2 {0} \
    PS_USE_PMCPL_CLK3 {0} \
    PS_USE_S_AXI_FPD {0} \
    SMON_ALARMS {Set_Alarms_On} \
    SMON_ENABLE_TEMP_AVERAGING {0} \
    SMON_TEMP_AVERAGING_SAMPLES {0} \
  } \
] $versal_cips_0



# -----------------------------------------------------------------------------
# AXI Uartlite
# -----------------------------------------------------------------------------

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
make_bd_intf_pins_external  [get_bd_intf_pins axi_uartlite_0/UART]
make_bd_pins_external  [get_bd_pins axi_uartlite_0/interrupt]

# -----------------------------------------------------------------------------
# AXI helper plane in PL
# -----------------------------------------------------------------------------

set axi_jtag [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_jtag:1.0 axi_jtag]

set axi_smc [create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc]
set_property -dict [list \
  CONFIG.NUM_MI {4} \
  CONFIG.NUM_SI {1} \
] $axi_smc

set rst_versal_cips [create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_versal_cips]

set axi_gpio [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio]
set_property -dict [list \
  CONFIG.C_ALL_OUTPUTS {1} \
  CONFIG.C_ALL_INPUTS_2 {1} \
  CONFIG.C_GPIO_WIDTH {5} \
  CONFIG.C_GPIO2_WIDTH {2} \
  CONFIG.C_IS_DUAL {1} \
] $axi_gpio

set ilconcat_0 [create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0]
set_property CONFIG.NUM_PORTS {2} $ilconcat_0

set ilconstant_0 [create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0]
set_property CONFIG.CONST_VAL {0} $ilconstant_0

set axi_quad_spi [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 axi_quad_spi]
set_property -dict [list \
  CONFIG.C_SPI_MODE {2} \
  CONFIG.C_USE_STARTUP {0} \
] $axi_quad_spi

# -----------------------------------------------------------------------------
# AXI interface connections
# -----------------------------------------------------------------------------

# Direct PS master to helper interconnect
connect_bd_intf_net [get_bd_intf_pins versal_cips_0/M_AXI_FPD] [get_bd_intf_pins axi_smc/S00_AXI]

connect_bd_intf_net [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins axi_gpio/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_smc/M01_AXI] [get_bd_intf_pins axi_jtag/s_axi]
connect_bd_intf_net [get_bd_intf_pins axi_smc/M02_AXI] [get_bd_intf_pins axi_quad_spi/AXI_LITE]
connect_bd_intf_net [get_bd_intf_pins axi_smc/M03_AXI] [get_bd_intf_pins axi_uartlite_0/S_AXI]

connect_bd_intf_net [get_bd_intf_ports ps_quadspi_io] [get_bd_intf_pins axi_quad_spi/SPI_0]

# -----------------------------------------------------------------------------
# Clocking
# -----------------------------------------------------------------------------

# PL clock 0 drives the internal helper AXI plane
connect_bd_net [get_bd_pins versal_cips_0/pl0_ref_clk] \
  [get_bd_pins versal_cips_0/m_axi_fpd_aclk] \
  [get_bd_pins axi_smc/aclk] \
  [get_bd_pins rst_versal_cips/slowest_sync_clk] \
  [get_bd_pins axi_jtag/s_axi_aclk] \
  [get_bd_pins axi_gpio/s_axi_aclk] \
  [get_bd_pins axi_uartlite_0/s_axi_aclk] \
  [get_bd_pins axi_quad_spi/s_axi_aclk] \
  [get_bd_pins axi_quad_spi/ext_spi_clk] 

# -----------------------------------------------------------------------------
# Reset
# -----------------------------------------------------------------------------

connect_bd_net [get_bd_pins versal_cips_0/pl0_resetn] \
  [get_bd_pins rst_versal_cips/ext_reset_in]

# Peripheral active-low resets
connect_bd_net [get_bd_pins rst_versal_cips/peripheral_aresetn] \
  [get_bd_pins axi_smc/aresetn] \
  [get_bd_pins axi_jtag/s_axi_aresetn] \
  [get_bd_pins axi_gpio/s_axi_aresetn] \
  [get_bd_pins axi_uartlite_0/s_axi_aresetn] \
  [get_bd_pins axi_quad_spi/s_axi_aresetn] 

# -----------------------------------------------------------------------------
# GPIO / JTAG / IRQ connections
# -----------------------------------------------------------------------------

connect_bd_net [get_bd_pins axi_gpio/gpio_io_o]  [get_bd_ports ps_gpio_o]
connect_bd_net [get_bd_ports ps_gpio_i]          [get_bd_pins axi_gpio/gpio2_io_i]

connect_bd_net [get_bd_pins axi_jtag/tck] [get_bd_ports ps_tck_o]
connect_bd_net [get_bd_pins axi_jtag/tdi] [get_bd_ports ps_tdi_o]
connect_bd_net [get_bd_pins axi_jtag/tms] [get_bd_ports ps_tms_o]
connect_bd_net [get_bd_ports ps_tdo_i]    [get_bd_pins axi_jtag/tdo]

# Only SPI interrupt used for now
connect_bd_net [get_bd_pins ilconstant_0/dout]         [get_bd_pins ilconcat_0/In0]
connect_bd_net [get_bd_pins axi_quad_spi/ip2intc_irpt] [get_bd_pins ilconcat_0/In1]
connect_bd_net [get_bd_pins ilconcat_0/dout]           [get_bd_pins versal_cips_0/pl_ps_irq0]

# -----------------------------------------------------------------------------
# Address map for direct M_AXI_FPD helper plane
# -----------------------------------------------------------------------------

assign_bd_address -offset 0xA4020000 -range 0x00010000 -with_name SEG_axi_gpio_Reg \
  -target_address_space [get_bd_addr_spaces versal_cips_0/M_AXI_FPD] \
  [get_bd_addr_segs axi_gpio/S_AXI/Reg] -force

assign_bd_address -offset 0xA4000000 -range 0x00010000 \
  -target_address_space [get_bd_addr_spaces versal_cips_0/M_AXI_FPD] \
  [get_bd_addr_segs axi_jtag/s_axi/reg0] -force


assign_bd_address -offset 0xA4040000 -range 0x00010000 -with_name SEG_axi_uartlite_Reg \
  -target_address_space [get_bd_addr_spaces versal_cips_0/M_AXI_FPD] \
  [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] -force

assign_bd_address -offset 0xA4030000 -range 0x00010000 -with_name SEG_axi_quad_spi_Reg \
  -target_address_space [get_bd_addr_spaces versal_cips_0/M_AXI_FPD] \
  [get_bd_addr_segs axi_quad_spi/AXI_LITE/Reg] -force

# -----------------------------------------------------------------------------
# Export PL clock 1 as external port
# -----------------------------------------------------------------------------



create_bd_port -dir O -type rst pl0_resetn
connect_bd_net [get_bd_ports pl0_resetn] [get_bd_pins rst_versal_cips/peripheral_aresetn]


# -----------------------------------------------------------------------------
# Finalize
# -----------------------------------------------------------------------------

validate_bd_design
save_bd_design
close_bd_design $design_name

set wrapper_path [make_wrapper -fileset sources_1 -files [get_files -norecurse xilinx_ps_wizard.bd] -top]
add_files -norecurse -fileset sources_1 $wrapper_path
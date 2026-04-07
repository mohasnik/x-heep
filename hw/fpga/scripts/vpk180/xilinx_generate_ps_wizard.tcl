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

set ps_quadspi_io [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 ps_quadspi_io ]

set ps_uart_rx_i [ create_bd_port -dir I ps_uart_rx_i ]
set ps_uart_tx_o [ create_bd_port -dir O ps_uart_tx_o ]
set ps_tdi_o     [ create_bd_port -dir O ps_tdi_o ]
set ps_tms_o     [ create_bd_port -dir O ps_tms_o ]
set ps_tck_o     [ create_bd_port -dir O ps_tck_o ]
set ps_tdo_i     [ create_bd_port -dir I ps_tdo_i ]
set ps_gpio_i    [ create_bd_port -dir I -from 1 -to 0 ps_gpio_i ]
set ps_gpio_o    [ create_bd_port -dir O -from 4 -to 0 ps_gpio_o ]


set versal_cips_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips versal_cips_0 ]
set_property -dict [list \
  CONFIG.PS_PMC_CONFIG { \
    CLOCK_MODE {Custom} \
    PS_NUM_FABRIC_RESETS {1} \
    PS_USE_PMCPL_CLK0 {1} \
    PS_PL_CLK0_BUF {1} \
    PS_USE_PMCPL_CLK1 {0} \
    PS_USE_PMCPL_CLK2 {0} \
    PS_USE_PMCPL_CLK3 {0} \
    PMC_CRP_PL0_REF_CTRL_FREQMHZ {100} \
    PS_USE_M_AXI_FPD {1} \
    PS_M_AXI_FPD_DATA_WIDTH {32} \
    PS_USE_S_AXI_FPD {0} \
  } \
  CONFIG.DDR_MEMORY_MODE {NO_DDR} \
] $versal_cips_0


set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc axi_noc_0 ]
set_property -dict [list \
  CONFIG.NUM_SI {1} \
  CONFIG.NUM_MI {1} \
  CONFIG.NUM_CLKS {1} \
  CONFIG.NUM_MC {0} \
  CONFIG.NUM_MCP {0} \
  CONFIG.NUM_NSI {0} \
  CONFIG.NUM_NMI {0} \
] $axi_noc_0


set_property -dict [list \
  CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
  CONFIG.CATEGORY {ps_pmc} \
] [get_bd_intf_pins axi_noc_0/S00_AXI]


set_property -dict [list \
  CONFIG.CATEGORY {pl} \
] [get_bd_intf_pins axi_noc_0/M00_AXI]


set_property CONFIG.ASSOCIATED_BUSIF {S00_AXI:M00_AXI} [get_bd_pins axi_noc_0/aclk0]

set axi_uartlite [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite ]

set axi_jtag [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_jtag:1.0 axi_jtag ]


set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
set_property -dict [list \
  CONFIG.NUM_MI {4} \
  CONFIG.NUM_SI {1} \
] $axi_smc


set rst_versal_cips [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_versal_cips ]


set axi_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio ]
set_property -dict [list \
  CONFIG.C_ALL_OUTPUTS {1} \
  CONFIG.C_ALL_INPUTS_2 {1} \
  CONFIG.C_GPIO_WIDTH {5} \
  CONFIG.C_GPIO2_WIDTH {2} \
  CONFIG.C_IS_DUAL {1} \
] $axi_gpio


set ilconcat_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ilconcat_0 ]
set_property CONFIG.NUM_PORTS {3} $ilconcat_0


set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]
set_property CONFIG.CONST_VAL {0} $ilconstant_0


set axi_quad_spi [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 axi_quad_spi ]
set_property -dict [list \
  CONFIG.C_SPI_MODE {2} \
  CONFIG.C_USE_STARTUP {0} \
] $axi_quad_spi



connect_bd_intf_net [get_bd_intf_pins versal_cips_0/M_AXI_FPD] [get_bd_intf_pins axi_noc_0/S00_AXI]


connect_bd_intf_net [get_bd_intf_pins axi_noc_0/M00_AXI] [get_bd_intf_pins axi_smc/S00_AXI]


connect_bd_intf_net [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins axi_gpio/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_smc/M01_AXI] [get_bd_intf_pins axi_jtag/s_axi]
connect_bd_intf_net [get_bd_intf_pins axi_smc/M02_AXI] [get_bd_intf_pins axi_uartlite/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_smc/M03_AXI] [get_bd_intf_pins axi_quad_spi/AXI_LITE]


connect_bd_intf_net [get_bd_intf_ports ps_quadspi_io] [get_bd_intf_pins axi_quad_spi/SPI_0]

connect_bd_net [get_bd_pins versal_cips_0/pl0_ref_clk] \
  [get_bd_pins axi_noc_0/aclk0] \
  [get_bd_pins axi_smc/aclk] \
  [get_bd_pins rst_versal_cips/slowest_sync_clk] \
  [get_bd_pins axi_jtag/s_axi_aclk] \
  [get_bd_pins axi_uartlite/s_axi_aclk] \
  [get_bd_pins axi_gpio/s_axi_aclk] \
  [get_bd_pins axi_quad_spi/s_axi_aclk] \
  [get_bd_pins axi_quad_spi/ext_spi_clk]

connect_bd_net [get_bd_pins versal_cips_0/pl0_resetn] \
  [get_bd_pins rst_versal_cips/ext_reset_in]

connect_bd_net [get_bd_pins rst_versal_cips/peripheral_aresetn] \
  [get_bd_pins axi_smc/aresetn] \
  [get_bd_pins axi_jtag/s_axi_aresetn] \
  [get_bd_pins axi_uartlite/s_axi_aresetn] \
  [get_bd_pins axi_gpio/s_axi_aresetn] \
  [get_bd_pins axi_quad_spi/s_axi_aresetn]

connect_bd_net [get_bd_pins axi_gpio/gpio_io_o] \
  [get_bd_ports ps_gpio_o]

connect_bd_net [get_bd_ports ps_gpio_i] \
  [get_bd_pins axi_gpio/gpio2_io_i]


connect_bd_net [get_bd_pins axi_jtag/tck] [get_bd_ports ps_tck_o]
connect_bd_net [get_bd_pins axi_jtag/tdi] [get_bd_ports ps_tdi_o]
connect_bd_net [get_bd_pins axi_jtag/tms] [get_bd_ports ps_tms_o]
connect_bd_net [get_bd_ports ps_tdo_i]    [get_bd_pins axi_jtag/tdo]


connect_bd_net [get_bd_pins axi_uartlite/tx] [get_bd_ports ps_uart_tx_o]
connect_bd_net [get_bd_ports ps_uart_rx_i]   [get_bd_pins axi_uartlite/rx]


connect_bd_net [get_bd_pins ilconstant_0/dout]            [get_bd_pins ilconcat_0/In0]
connect_bd_net [get_bd_pins axi_uartlite/interrupt]       [get_bd_pins ilconcat_0/In1]
connect_bd_net [get_bd_pins axi_quad_spi/ip2intc_irpt]    [get_bd_pins ilconcat_0/In2]
connect_bd_net [get_bd_pins ilconcat_0/dout]              [get_bd_pins versal_cips_0/pl_ps_irq0]


assign_bd_address -offset 0xA0020000 -range 0x00010000 -with_name SEG_axi_gpio_Reg \
  -target_address_space [get_bd_addr_spaces versal_cips_0/Data] \
  [get_bd_addr_segs axi_gpio/S_AXI/Reg] -force

assign_bd_address -offset 0xA0000000 -range 0x00010000 \
  -target_address_space [get_bd_addr_spaces versal_cips_0/Data] \
  [get_bd_addr_segs axi_jtag/s_axi/reg0] -force

assign_bd_address -offset 0xA0030000 -range 0x00010000 -with_name SEG_axi_quad_spi_Reg \
  -target_address_space [get_bd_addr_spaces versal_cips_0/Data] \
  [get_bd_addr_segs axi_quad_spi/AXI_LITE/Reg] -force

assign_bd_address -offset 0xA0010000 -range 0x00010000 -with_name SEG_axi_uartlite_Reg \
  -target_address_space [get_bd_addr_spaces versal_cips_0/Data] \
  [get_bd_addr_segs axi_uartlite/S_AXI/Reg] -force


validate_bd_design
save_bd_design
close_bd_design $design_name

set wrapper_path [ make_wrapper -fileset sources_1 -files [ get_files -norecurse xilinx_ps_wizard.bd ] -top ]
add_files -norecurse -fileset sources_1 $wrapper_path

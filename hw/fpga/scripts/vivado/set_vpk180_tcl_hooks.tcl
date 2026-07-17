# Copyright (C) 2026 EPFL.
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# File: set_vpk180_tcl_hooks.tcl
# Author: Mohammad Hossein Nikkhah
# Description: 

set here [file dirname [info script]]
set eco [file normalize [file join $here "eco_spi_flash_mux_vpk180_pre_opt.tcl"]]

puts "INFO: Attaching VPK180 SPI flash mux ECO before opt_design: $eco"
set_property -name {STEPS.OPT_DESIGN.TCL.PRE} -value $eco -objects [get_runs impl_1]
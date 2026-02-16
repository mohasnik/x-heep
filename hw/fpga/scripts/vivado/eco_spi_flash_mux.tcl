# ECO script to multiplex QuadSPI spi signals between PS (axi_quad_spi in PL) and X-HEEP
# The mux output drives the X-HEEP pad-ring IOBUFs connected to top-level ports spi_flash_*.
# Run AFTER opt_design, BEFORE place_design.
#
# X-HEEP has IOBUFs in pad_ring for spi_flash signals
# PS has IOBUFs in xilinx_ps_wizard_wrapper for ps_quadspi signals
# Both connect to the same physical spi (shared)
# SEL signal (ps_x_heep_o[4]): 0=X-HEEP controls spi, 1=PS controls spi
#
# What this script does:
#   1. Remove PS IOBUFs
#   2. Create MUX logic that selects between X-HEEP and PS output signals
#   3. Drive X-HEEP IOBUFs with muxed signals
#   4. Feed X-HEEP IOBUF.O (data from spi) back to PS axi_quad_spi inputs

# Get the MUX select signal from the DONT_TOUCH LUT
set keep_sel_pin [lindex [get_pins -quiet -hier -filter {NAME =~ "*u_keep_ps_spi_flash_sel/I0"}] 0]
set SEL [lindex [get_nets -quiet -of_objects $keep_sel_pin] 0]

# Find X-HEEP IOBUFs (in pad_ring)
set X_IOBUF_SD0 [lindex [get_cells -quiet -hier -filter {NAME =~ "*pad_ring_i/pad_spi_flash_sd_0_i/xilinx_iobuf_i"}] 0]
set X_IOBUF_SD1 [lindex [get_cells -quiet -hier -filter {NAME =~ "*pad_ring_i/pad_spi_flash_sd_1_i/xilinx_iobuf_i"}] 0]
set X_IOBUF_SD2 [lindex [get_cells -quiet -hier -filter {NAME =~ "*pad_ring_i/pad_spi_flash_sd_2_i/xilinx_iobuf_i"}] 0]
set X_IOBUF_SD3 [lindex [get_cells -quiet -hier -filter {NAME =~ "*pad_ring_i/pad_spi_flash_sd_3_i/xilinx_iobuf_i"}] 0]
set X_IOBUF_SCK [lindex [get_cells -quiet -hier -filter {NAME =~ "*pad_ring_i/pad_spi_flash_sck_i/xilinx_iobuf_i"}] 0]
set X_IOBUF_CS  [lindex [get_cells -quiet -hier -filter {NAME =~ "*pad_ring_i/pad_spi_flash_cs_0_i/xilinx_iobuf_i"}] 0]

# Get X-HEEP IOBUF pins and their current nets
set X_SD0_I_PIN [get_pins -quiet -of_objects $X_IOBUF_SD0 -filter {REF_PIN_NAME=="I"}]
set X_SD0_T_PIN [get_pins -quiet -of_objects $X_IOBUF_SD0 -filter {REF_PIN_NAME=="T"}]
set X_SD0_O_PIN [get_pins -quiet -of_objects $X_IOBUF_SD0 -filter {REF_PIN_NAME=="O"}]
set X_SD1_I_PIN [get_pins -quiet -of_objects $X_IOBUF_SD1 -filter {REF_PIN_NAME=="I"}]
set X_SD1_T_PIN [get_pins -quiet -of_objects $X_IOBUF_SD1 -filter {REF_PIN_NAME=="T"}]
set X_SD1_O_PIN [get_pins -quiet -of_objects $X_IOBUF_SD1 -filter {REF_PIN_NAME=="O"}]
set X_SD2_I_PIN [get_pins -quiet -of_objects $X_IOBUF_SD2 -filter {REF_PIN_NAME=="I"}]
set X_SD2_T_PIN [get_pins -quiet -of_objects $X_IOBUF_SD2 -filter {REF_PIN_NAME=="T"}]
set X_SD2_O_PIN [get_pins -quiet -of_objects $X_IOBUF_SD2 -filter {REF_PIN_NAME=="O"}]
set X_SD3_I_PIN [get_pins -quiet -of_objects $X_IOBUF_SD3 -filter {REF_PIN_NAME=="I"}]
set X_SD3_T_PIN [get_pins -quiet -of_objects $X_IOBUF_SD3 -filter {REF_PIN_NAME=="T"}]
set X_SD3_O_PIN [get_pins -quiet -of_objects $X_IOBUF_SD3 -filter {REF_PIN_NAME=="O"}]
set X_SCK_I_PIN [get_pins -quiet -of_objects $X_IOBUF_SCK -filter {REF_PIN_NAME=="I"}]
set X_SCK_T_PIN [get_pins -quiet -of_objects $X_IOBUF_SCK -filter {REF_PIN_NAME=="T"}]
set X_CS_I_PIN  [get_pins -quiet -of_objects $X_IOBUF_CS  -filter {REF_PIN_NAME=="I"}]
set X_CS_T_PIN  [get_pins -quiet -of_objects $X_IOBUF_CS  -filter {REF_PIN_NAME=="T"}]

# Get current nets connected to X-HEEP IOBUF pins (these are from X-HEEP's SPI controller)
set X_SD0_I_NET [get_nets -quiet -of_objects $X_SD0_I_PIN]
set X_SD0_T_NET [get_nets -quiet -of_objects $X_SD0_T_PIN]
set X_SD0_O_NET [get_nets -quiet -of_objects $X_SD0_O_PIN]
set X_SD1_I_NET [get_nets -quiet -of_objects $X_SD1_I_PIN]
set X_SD1_T_NET [get_nets -quiet -of_objects $X_SD1_T_PIN]
set X_SD1_O_NET [get_nets -quiet -of_objects $X_SD1_O_PIN]
set X_SD2_I_NET [get_nets -quiet -of_objects $X_SD2_I_PIN]
set X_SD2_T_NET [get_nets -quiet -of_objects $X_SD2_T_PIN]
set X_SD2_O_NET [get_nets -quiet -of_objects $X_SD2_O_PIN]
set X_SD3_I_NET [get_nets -quiet -of_objects $X_SD3_I_PIN]
set X_SD3_T_NET [get_nets -quiet -of_objects $X_SD3_T_PIN]
set X_SD3_O_NET [get_nets -quiet -of_objects $X_SD3_O_PIN]
set X_SCK_I_NET [get_nets -quiet -of_objects $X_SCK_I_PIN]
set X_SCK_T_NET [get_nets -quiet -of_objects $X_SCK_T_PIN]
set X_CS_I_NET  [get_nets -quiet -of_objects $X_CS_I_PIN]
set X_CS_T_NET  [get_nets -quiet -of_objects $X_CS_T_PIN]

# Find PS IOBUFs for bidirectional data (IO0-IO3)
set PS_IOBUF_IO0 [lindex [get_cells -quiet -hier -filter {NAME =~ "*xilinx_ps_wizard_wrapper_i/ps_quadspi_io_io0_iobuf"}] 0]
set PS_IOBUF_IO1 [lindex [get_cells -quiet -hier -filter {NAME =~ "*xilinx_ps_wizard_wrapper_i/ps_quadspi_io_io1_iobuf"}] 0]
set PS_IOBUF_IO2 [lindex [get_cells -quiet -hier -filter {NAME =~ "*xilinx_ps_wizard_wrapper_i/ps_quadspi_io_io2_iobuf"}] 0]
set PS_IOBUF_IO3 [lindex [get_cells -quiet -hier -filter {NAME =~ "*xilinx_ps_wizard_wrapper_i/ps_quadspi_io_io3_iobuf"}] 0]

# Get PS output signals (from axi_quad_spi, going external)
# For IO0-IO3, get from IOBUF.I and IOBUF.T
set PS_IO0_O [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_IO0 -filter {REF_PIN_NAME=="I"}]]
set PS_IO0_T [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_IO0 -filter {REF_PIN_NAME=="T"}]]
set PS_IO1_O [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_IO1 -filter {REF_PIN_NAME=="I"}]]
set PS_IO1_T [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_IO1 -filter {REF_PIN_NAME=="T"}]]
set PS_IO2_O [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_IO2 -filter {REF_PIN_NAME=="I"}]]
set PS_IO2_T [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_IO2 -filter {REF_PIN_NAME=="T"}]]
set PS_IO3_O [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_IO3 -filter {REF_PIN_NAME=="I"}]]
set PS_IO3_T [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_IO3 -filter {REF_PIN_NAME=="T"}]]

# Validate PS data O and T nets - search from axi_quad_spi pins if empty
foreach {idx o_var t_var} {0 PS_IO0_O PS_IO0_T 1 PS_IO1_O PS_IO1_T 2 PS_IO2_O PS_IO2_T 3 PS_IO3_O PS_IO3_T} {
  # Check output data net
  if {[set $o_var] eq ""} {
    set o_pin [lindex [get_pins -quiet -hier -filter "NAME =~ *axi_quad_spi*io${idx}_o*"] 0]
    if {$o_pin ne ""} {
      set $o_var [get_nets -quiet -of_objects $o_pin]
    }
  }
  # Check tristate net
  if {[set $t_var] eq ""} {
    set t_pin [lindex [get_pins -quiet -hier -filter "NAME =~ *axi_quad_spi*io${idx}_t*"] 0]
    if {$t_pin ne ""} {
      set $t_var [get_nets -quiet -of_objects $t_pin]
    }
  }
}

# For SCK and SS - find the IOBUFs and get nets from their pins
set PS_IOBUF_SCK [lindex [get_cells -quiet -hier -filter {NAME =~ "*xilinx_ps_wizard_wrapper_i/ps_quadspi_io_sck_iobuf"}] 0]
set PS_IOBUF_SS  [lindex [get_cells -quiet -hier -filter {NAME =~ "*xilinx_ps_wizard_wrapper_i/ps_quadspi_io_ss_iobuf_0"}] 0]

# Get nets from the IOBUF pins
set PS_SCK_O [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_SCK -filter {REF_PIN_NAME=="I"}]]
set PS_SCK_T [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_SCK -filter {REF_PIN_NAME=="T"}]]

set PS_SS_O [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_SS -filter {REF_PIN_NAME=="I"}]]
set PS_SS_T [get_nets -quiet -of_objects [get_pins -quiet -of_objects $PS_IOBUF_SS -filter {REF_PIN_NAME=="T"}]]

# Verify critical signals are found - if PS_SCK_O is empty, try to find it from axi_quad_spi output
if {$PS_SCK_O eq ""} {
  # Find the SCK output register directly
  set sck_reg [lindex [get_cells -quiet -hier -filter {NAME =~ "*axi_quad_spi*SCK_O*FDRE*"}] 0]
  if {$sck_reg ne ""} {
    set PS_SCK_O [get_nets -quiet -of_objects [get_pins -quiet -of_objects $sck_reg -filter {REF_PIN_NAME=="Q"}]]
  }
}


# Disable IOB property for PS input and output registers
# Input registers
foreach io_name {IO0_I_REG IO1_I_REG IO2_I_REG IO3_I_REG} {
  set ps_ff [lindex [get_cells -quiet -hier -filter "NAME =~ *xilinx_ps_wizard_i*axi_quad_spi*$io_name*"] 0]
  if {$ps_ff ne ""} {
    set_property IOB FALSE $ps_ff
  }
}

# Data output registers - disable IOB so they work after IOBUF removal
foreach io_name {IO0_O IO1_O IO2_O IO3_O} {
  set ps_ffs [get_cells -quiet -hier -filter "NAME =~ *axi_quad_spi*${io_name}*"]
  foreach ps_ff $ps_ffs {
    catch {set_property IOB FALSE $ps_ff}
  }
}

# Data tristate registers - disable IOB so they work after IOBUF removal
foreach io_name {IO0_T IO1_T IO2_T IO3_T} {
  set ps_ffs [get_cells -quiet -hier -filter "NAME =~ *axi_quad_spi*${io_name}*"]
  foreach ps_ff $ps_ffs {
    catch {set_property IOB FALSE $ps_ff}
  }
}

# SCK output register - disable IOB on ALL matching registers
# The pattern must match the exact register path: SPI_MODE_CONTROL_LOGIC_I/...SCK_O_NE_4_FDRE_INST
set sck_ffs [get_cells -quiet -hier -filter {NAME =~ "*axi_quad_spi*SCK_O*FDRE_INST"}]
if {[llength $sck_ffs] > 0} {
  foreach sck_ff $sck_ffs {
    set_property IOB FALSE $sck_ff
  }
}

# SS output register
set ss_ff [lindex [get_cells -quiet -hier -filter {NAME =~ "*axi_quad_spi*SS_O*FDRE*"}] 0]
if {$ss_ff ne ""} {
  set_property IOB FALSE $ss_ff
}

# Remove the DONT_TOUCH LUTs that were used to keep SCK/SS signals alive
set keep_sck_lut [lindex [get_cells -quiet -hier -filter {NAME =~ "*u_keep_ps_quadspi_sck"}] 0]
set keep_ss_lut [lindex [get_cells -quiet -hier -filter {NAME =~ "*u_keep_ps_quadspi_ss"}] 0]

if {$keep_sck_lut ne ""} {
  reset_property DONT_TOUCH $keep_sck_lut
  remove_cell $keep_sck_lut
}

if {$keep_ss_lut ne ""} {
  reset_property DONT_TOUCH $keep_ss_lut
  remove_cell $keep_ss_lut
}

# Remove DONT_TOUCH from the top-level nets so they can be cleaned up after IOBUF removal
set sck_net [lindex [get_nets -quiet -hier -filter {NAME =~ "ps_quadspi_io_sck_io"}] 0]
set ss_net [lindex [get_nets -quiet -hier -filter {NAME =~ "ps_quadspi_io_ss_io"}] 0]
if {$sck_net ne ""} {
  reset_property DONT_TOUCH $sck_net
}
if {$ss_net ne ""} {
  reset_property DONT_TOUCH $ss_net
}

# Remove PS IOBUFs
if {$PS_IOBUF_IO0 ne ""} { remove_cell $PS_IOBUF_IO0 }
if {$PS_IOBUF_IO1 ne ""} { remove_cell $PS_IOBUF_IO1 }
if {$PS_IOBUF_IO2 ne ""} { remove_cell $PS_IOBUF_IO2 }
if {$PS_IOBUF_IO3 ne ""} { remove_cell $PS_IOBUF_IO3 }
if {$PS_IOBUF_SCK ne ""} { remove_cell $PS_IOBUF_SCK }
if {$PS_IOBUF_SS  ne ""} { remove_cell $PS_IOBUF_SS }

# Disconnect X-HEEP IOBUF inputs from X-HEEP signals
disconnect_net -net $X_SD0_I_NET -objects $X_SD0_I_PIN
disconnect_net -net $X_SD0_T_NET -objects $X_SD0_T_PIN
disconnect_net -net $X_SD1_I_NET -objects $X_SD1_I_PIN
disconnect_net -net $X_SD1_T_NET -objects $X_SD1_T_PIN
disconnect_net -net $X_SD2_I_NET -objects $X_SD2_I_PIN
disconnect_net -net $X_SD2_T_NET -objects $X_SD2_T_PIN
disconnect_net -net $X_SD3_I_NET -objects $X_SD3_I_PIN
disconnect_net -net $X_SD3_T_NET -objects $X_SD3_T_PIN
disconnect_net -net $X_SCK_I_NET -objects $X_SCK_I_PIN
disconnect_net -net $X_SCK_T_NET -objects $X_SCK_T_PIN
disconnect_net -net $X_CS_I_NET  -objects $X_CS_I_PIN
disconnect_net -net $X_CS_T_NET  -objects $X_CS_T_PIN

# Create MUX LUTs
# LUT3 with INIT=8'hCA implements: O = SEL ? I1 : I0
# When SEL=0 (X-HEEP mode): output = I0 (X-HEEP signal)
# When SEL=1 (PS mode):     output = I1 (PS signal)

# Create nets for mux outputs
create_net ECO_MUX_SD0_I
create_net ECO_MUX_SD0_T
create_net ECO_MUX_SD1_I
create_net ECO_MUX_SD1_T
create_net ECO_MUX_SD2_I
create_net ECO_MUX_SD2_T
create_net ECO_MUX_SD3_I
create_net ECO_MUX_SD3_T
create_net ECO_MUX_SCK_I
create_net ECO_MUX_SCK_T
create_net ECO_MUX_CS_I
create_net ECO_MUX_CS_T

# SD0 data mux
create_cell -reference LUT3 ECO_MUX_SD0_I_LUT
set_property INIT 8'hCA [get_cells ECO_MUX_SD0_I_LUT]
connect_net -hier -net $X_SD0_I_NET -objects [get_pins ECO_MUX_SD0_I_LUT/I0]
connect_net -hier -net $PS_IO0_O    -objects [get_pins ECO_MUX_SD0_I_LUT/I1]
connect_net -hier -net $SEL         -objects [get_pins ECO_MUX_SD0_I_LUT/I2]
connect_net -hier -net ECO_MUX_SD0_I -objects [get_pins ECO_MUX_SD0_I_LUT/O]

# SD0 tristate mux - Force T=0 in PS mode (output always enabled)
# LUT2 INIT=4'h1: O = ~I1 & I0 → when SEL=1(PS): T=0, when SEL=0(X-HEEP): T=X_SD0_T
create_cell -reference LUT2 ECO_MUX_SD0_T_LUT
set_property INIT 4'h1 [get_cells ECO_MUX_SD0_T_LUT]
connect_net -hier -net $X_SD0_T_NET -objects [get_pins ECO_MUX_SD0_T_LUT/I0]
connect_net -hier -net $SEL         -objects [get_pins ECO_MUX_SD0_T_LUT/I1]
connect_net -hier -net ECO_MUX_SD0_T -objects [get_pins ECO_MUX_SD0_T_LUT/O]

# SD1 data mux
create_cell -reference LUT3 ECO_MUX_SD1_I_LUT
set_property INIT 8'hCA [get_cells ECO_MUX_SD1_I_LUT]
connect_net -hier -net $X_SD1_I_NET -objects [get_pins ECO_MUX_SD1_I_LUT/I0]
connect_net -hier -net $PS_IO1_O    -objects [get_pins ECO_MUX_SD1_I_LUT/I1]
connect_net -hier -net $SEL         -objects [get_pins ECO_MUX_SD1_I_LUT/I2]
connect_net -hier -net ECO_MUX_SD1_I -objects [get_pins ECO_MUX_SD1_I_LUT/O]

# SD1 tristate mux - Force T=0 in PS mode (output always enabled)
create_cell -reference LUT2 ECO_MUX_SD1_T_LUT
set_property INIT 4'h1 [get_cells ECO_MUX_SD1_T_LUT]
connect_net -hier -net $X_SD1_T_NET -objects [get_pins ECO_MUX_SD1_T_LUT/I0]
connect_net -hier -net $SEL         -objects [get_pins ECO_MUX_SD1_T_LUT/I1]
connect_net -hier -net ECO_MUX_SD1_T -objects [get_pins ECO_MUX_SD1_T_LUT/O]

# SD2 data mux
create_cell -reference LUT3 ECO_MUX_SD2_I_LUT
set_property INIT 8'hCA [get_cells ECO_MUX_SD2_I_LUT]
connect_net -hier -net $X_SD2_I_NET -objects [get_pins ECO_MUX_SD2_I_LUT/I0]
connect_net -hier -net $PS_IO2_O    -objects [get_pins ECO_MUX_SD2_I_LUT/I1]
connect_net -hier -net $SEL         -objects [get_pins ECO_MUX_SD2_I_LUT/I2]
connect_net -hier -net ECO_MUX_SD2_I -objects [get_pins ECO_MUX_SD2_I_LUT/O]

# SD2 tristate mux - Force T=0 in PS mode (output always enabled)
create_cell -reference LUT2 ECO_MUX_SD2_T_LUT
set_property INIT 4'h1 [get_cells ECO_MUX_SD2_T_LUT]
connect_net -hier -net $X_SD2_T_NET -objects [get_pins ECO_MUX_SD2_T_LUT/I0]
connect_net -hier -net $SEL         -objects [get_pins ECO_MUX_SD2_T_LUT/I1]
connect_net -hier -net ECO_MUX_SD2_T -objects [get_pins ECO_MUX_SD2_T_LUT/O]

# SD3 data mux
create_cell -reference LUT3 ECO_MUX_SD3_I_LUT
set_property INIT 8'hCA [get_cells ECO_MUX_SD3_I_LUT]
connect_net -hier -net $X_SD3_I_NET -objects [get_pins ECO_MUX_SD3_I_LUT/I0]
connect_net -hier -net $PS_IO3_O    -objects [get_pins ECO_MUX_SD3_I_LUT/I1]
connect_net -hier -net $SEL         -objects [get_pins ECO_MUX_SD3_I_LUT/I2]
connect_net -hier -net ECO_MUX_SD3_I -objects [get_pins ECO_MUX_SD3_I_LUT/O]

# SD3 tristate mux - Force T=0 in PS mode (output always enabled)
create_cell -reference LUT2 ECO_MUX_SD3_T_LUT
set_property INIT 4'h1 [get_cells ECO_MUX_SD3_T_LUT]
connect_net -hier -net $X_SD3_T_NET -objects [get_pins ECO_MUX_SD3_T_LUT/I0]
connect_net -hier -net $SEL         -objects [get_pins ECO_MUX_SD3_T_LUT/I1]
connect_net -hier -net ECO_MUX_SD3_T -objects [get_pins ECO_MUX_SD3_T_LUT/O]

# SCK mux
create_cell -reference LUT3 ECO_MUX_SCK_I_LUT
set_property INIT 8'hCA [get_cells ECO_MUX_SCK_I_LUT]
connect_net -hier -net $X_SCK_I_NET -objects [get_pins ECO_MUX_SCK_I_LUT/I0]
connect_net -hier -net $PS_SCK_O    -objects [get_pins ECO_MUX_SCK_I_LUT/I1]
connect_net -hier -net $SEL         -objects [get_pins ECO_MUX_SCK_I_LUT/I2]
connect_net -hier -net ECO_MUX_SCK_I -objects [get_pins ECO_MUX_SCK_I_LUT/O]

# SCK tristate mux - SCK is OUTPUT-ONLY, so when in PS mode we FORCE T=0 (output enabled)
# The axi_quad_spi might keep T=1 when idle, which would disable output!
# Solution: Use LUT2 with INIT=0x1 → O = SEL ? 0 : I0
# When SEL=1 (PS mode), force output enabled (T=0)
# When SEL=0 (X-HEEP mode), use X-HEEP tristate signal

create_cell -reference LUT2 ECO_MUX_SCK_T_LUT
set_property INIT 4'h1 [get_cells ECO_MUX_SCK_T_LUT]
connect_net -hier -net $X_SCK_T_NET -objects [get_pins ECO_MUX_SCK_T_LUT/I0]
connect_net -hier -net $SEL         -objects [get_pins ECO_MUX_SCK_T_LUT/I1]
connect_net -hier -net ECO_MUX_SCK_T -objects [get_pins ECO_MUX_SCK_T_LUT/O]

# CS mux
create_cell -reference LUT3 ECO_MUX_CS_I_LUT
set_property INIT 8'hCA [get_cells ECO_MUX_CS_I_LUT]
connect_net -hier -net $X_CS_I_NET -objects [get_pins ECO_MUX_CS_I_LUT/I0]
connect_net -hier -net $PS_SS_O    -objects [get_pins ECO_MUX_CS_I_LUT/I1]
connect_net -hier -net $SEL        -objects [get_pins ECO_MUX_CS_I_LUT/I2]
connect_net -hier -net ECO_MUX_CS_I -objects [get_pins ECO_MUX_CS_I_LUT/O]

# CS tristate mux - CS (SS) is OUTPUT-ONLY, force T=0 in PS mode
# Use LUT2 with INIT=0x1 → O = SEL ? 0 : I0
create_cell -reference LUT2 ECO_MUX_CS_T_LUT
set_property INIT 4'h1 [get_cells ECO_MUX_CS_T_LUT]
connect_net -hier -net $X_CS_T_NET -objects [get_pins ECO_MUX_CS_T_LUT/I0]
connect_net -hier -net $SEL        -objects [get_pins ECO_MUX_CS_T_LUT/I1]
connect_net -hier -net ECO_MUX_CS_T -objects [get_pins ECO_MUX_CS_T_LUT/O]

# Connect MUX outputs to X-HEEP IOBUFs
connect_net -hier -net ECO_MUX_SD0_I -objects [list $X_SD0_I_PIN]
connect_net -hier -net ECO_MUX_SD0_T -objects [list $X_SD0_T_PIN]
connect_net -hier -net ECO_MUX_SD1_I -objects [list $X_SD1_I_PIN]
connect_net -hier -net ECO_MUX_SD1_T -objects [list $X_SD1_T_PIN]
connect_net -hier -net ECO_MUX_SD2_I -objects [list $X_SD2_I_PIN]
connect_net -hier -net ECO_MUX_SD2_T -objects [list $X_SD2_T_PIN]
connect_net -hier -net ECO_MUX_SD3_I -objects [list $X_SD3_I_PIN]
connect_net -hier -net ECO_MUX_SD3_T -objects [list $X_SD3_T_PIN]
connect_net -hier -net ECO_MUX_SCK_I -objects [list $X_SCK_I_PIN]
connect_net -hier -net ECO_MUX_SCK_T -objects [list $X_SCK_T_PIN]
connect_net -hier -net ECO_MUX_CS_I  -objects [list $X_CS_I_PIN]
connect_net -hier -net ECO_MUX_CS_T  -objects [list $X_CS_T_PIN]

# Connect X-HEEP IOBUF.O (flash read data) to PS axi_quad_spi inputs
# The PS needs to receive data from flash when it's the active controller
# X-HEEP IOBUF.O carries data from flash, this goes to both X-HEEP and PS

# Find the actual axi_quad_spi input pins and reconnect
foreach {idx x_o_net} [list 0 $X_SD0_O_NET 1 $X_SD1_O_NET 2 $X_SD2_O_NET 3 $X_SD3_O_NET] {
  # Try multiple patterns to find the input pin
  set qspi_pin ""
  foreach pattern [list "*axi_quad_spi/io${idx}_i" "*axi_quad_spi*/io${idx}_i*" "*axi_quad_spi*io${idx}_i*"] {
    set qspi_pin [lindex [get_pins -quiet -hier -filter "NAME =~ $pattern"] 0]
    if {$qspi_pin ne ""} {
      break
    }
  }
  
  if {$qspi_pin ne ""} {
    set old_net [get_nets -quiet -of_objects $qspi_pin]
    if {$old_net ne ""} {
      disconnect_net -net $old_net -objects $qspi_pin
    }
    connect_net -hier -net $x_o_net -objects [list $qspi_pin]
  }
}

# Find and tie SS input high to prevent Slave_Mode_Err
set ss_input_pin [lindex [get_pins -quiet -hier -filter "NAME =~ *axi_quad_spi*ss_i*"] 0]
if {$ss_input_pin ne ""} {
  set old_ss_net [get_nets -quiet -of_objects $ss_input_pin]
  if {$old_ss_net ne ""} {
    disconnect_net -net $old_ss_net -objects $ss_input_pin
  }
  # Create VCC to tie SS input high (inactive, prevents MODF/Slave_Mode_Err)
  catch {create_cell -reference VCC ECO_VCC_SS_INPUT}
  catch {create_net ECO_SS_INPUT_HIGH}
  set vcc_pin [get_pins -quiet ECO_VCC_SS_INPUT/P]
  if {$vcc_pin ne ""} {
    connect_net -hier -net ECO_SS_INPUT_HIGH -objects $vcc_pin
    connect_net -hier -net ECO_SS_INPUT_HIGH -objects [list $ss_input_pin]
  } else {
    # Fallback: find existing VCC net in design
    set existing_vcc [lindex [get_nets -quiet -hier -filter {NAME =~ *VCC* || NAME =~ *vcc*}] 0]
    if {$existing_vcc ne ""} {
      connect_net -hier -net $existing_vcc -objects [list $ss_input_pin]
    }
  }
}
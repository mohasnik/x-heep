# ECO script to multiplex SPI flash signals between PS and X-HEEP
# This should run AFTER opt_design in the implementation flow

set PORT_SCK {spi_flash_sck_o}
set PORT_CS  {spi_flash_csb_o}
set PORT_SD0 {spi_flash_sd_io[0]}
set PORT_SD1 {spi_flash_sd_io[1]}

# Find PS SPI pins
set ps_sck_pin  [lindex [get_pins -quiet -hier -filter {NAME =~ "*xilinx_ps_wizard_wrapper_i/ps_spi_flash_sck_o"}] 0]
set ps_cs_pin   [lindex [get_pins -quiet -hier -filter {NAME =~ "*xilinx_ps_wizard_wrapper_i/ps_spi_flash_cs_o*"}] 0]
set ps_mosi_pin [lindex [get_pins -quiet -hier -filter {NAME =~ "*xilinx_ps_wizard_wrapper_i/ps_spi_flash_mosi_o"}] 0]
set ps_miso_pin [lindex [get_pins -quiet -hier -regexp {^xilinx_ps_wizard_wrapper_i(/xilinx_ps_wizard_i)?/ps_spi_flash_miso_i$}] 0]

# Get PS SPI nets
set PS_SCK          [lindex [get_nets -quiet -of_objects $ps_sck_pin] 0]
set PS_CS           [lindex [get_nets -quiet -of_objects $ps_cs_pin] 0]
set PS_MOSI         [lindex [get_nets -quiet -of_objects $ps_mosi_pin] 0]
set PS_MISO_NET_INT [lindex [get_nets -quiet -of_objects $ps_miso_pin] 0]

# Find selection signal (ps_gpio_o[4])
set sel_net [get_nets -quiet -hier -regexp {ps_x_heep_o(__0)?\[4\]}]
set SEL [lindex $sel_net 0]

# Get port nets
set NET_SCK_PORT [lindex [get_nets -quiet -of_objects [get_ports $PORT_SCK]] 0]
set NET_CS_PORT  [lindex [get_nets -quiet -of_objects [get_ports $PORT_CS]] 0]
set NET_SD0_PORT [lindex [get_nets -quiet -of_objects [get_ports $PORT_SD0]] 0]
set NET_SD1_PORT [lindex [get_nets -quiet -of_objects [get_ports $PORT_SD1]] 0]

set ps_miso_hpin [lindex [get_pins -quiet -of_objects $PS_MISO_NET_INT -filter {NAME =~ "xilinx_ps_wizard_wrapper_i/*" && NAME !~ "*xilinx_ps_wizard_i/*"}] 0]
set ps_miso_hpin_net_old [lindex [get_nets -quiet -of_objects $ps_miso_hpin] 0]
set do_connect 1
if {$ps_miso_hpin_net_old ne ""} {
  if {[get_property NAME $ps_miso_hpin_net_old] eq [get_property NAME $NET_SD1_PORT]} {
    set do_connect 0
  } else {
    disconnect_net -net $ps_miso_hpin_net_old -objects $ps_miso_hpin
  }
}
if {$do_connect} {
  connect_net -hier -net $NET_SD1_PORT -objects [list $ps_miso_hpin]
}

# SD0 IOBUF modifications
set SD0_IOBUF [get_cells -quiet -hier -filter {REF_NAME == IOBUF && NAME =~ "*pad_spi_flash_sd_0*"}]
if {[llength $SD0_IOBUF] == 0} {
  set SD0_IOBUF [get_cells -quiet -hier -filter {REF_NAME == IOBUF && NAME =~ "*spi_flash_sd*0*"}]
}
set SD0_IOBUF [lindex $SD0_IOBUF 0]

set SD0_PIN_IO     [lindex [get_pins -quiet -of_objects $SD0_IOBUF -filter {REF_PIN_NAME=="IO"}] 0]
set SD0_NET_IO_OLD [lindex [get_nets -quiet -of_objects $SD0_PIN_IO] 0]
disconnect_net -net $SD0_NET_IO_OLD -objects $SD0_PIN_IO
connect_net -hier -net $NET_SD0_PORT -objects [list $SD0_PIN_IO]

set SD0_PIN_I     [lindex [get_pins -quiet -of_objects $SD0_IOBUF -filter {REF_PIN_NAME=="I"}] 0]
set SD0_NET_I_OLD [lindex [get_nets -quiet -of_objects $SD0_PIN_I] 0]
disconnect_net -net $SD0_NET_I_OLD -objects $SD0_PIN_I

create_net SD0_ECO_I
create_cell -reference LUT3 SD0_LUTI
set_property INIT 8'hCA [get_cells SD0_LUTI]
connect_net -hier -net $SD0_NET_I_OLD -objects [list [get_pins SD0_LUTI/I0]]
connect_net -hier -net $PS_MOSI       -objects [list [get_pins SD0_LUTI/I1]]
connect_net -hier -net $SEL           -objects [list [get_pins SD0_LUTI/I2]]
connect_net -hier -net SD0_ECO_I      -objects [list [get_pins SD0_LUTI/O] $SD0_PIN_I]

set SD0_PIN_T     [lindex [get_pins -quiet -of_objects $SD0_IOBUF -filter {REF_PIN_NAME=="T"}] 0]
set SD0_NET_T_OLD [lindex [get_nets -quiet -of_objects $SD0_PIN_T] 0]
disconnect_net -net $SD0_NET_T_OLD -objects $SD0_PIN_T

create_net SD0_ECO_T
create_cell -reference LUT2 SD0_LUTT
set_property INIT 4'h8 [get_cells SD0_LUTT]
connect_net -hier -net $SD0_NET_T_OLD -objects [list [get_pins SD0_LUTT/I0]]
connect_net -hier -net $SEL           -objects [list [get_pins SD0_LUTT/I1]]
connect_net -hier -net SD0_ECO_T      -objects [list [get_pins SD0_LUTT/O] $SD0_PIN_T]

# SD1 IOBUF modifications
set SD1_IOBUF [get_cells -quiet -hier -filter {REF_NAME == IOBUF && NAME =~ "*pad_spi_flash_sd_1*"}]
if {[llength $SD1_IOBUF] == 0} {
  set SD1_IOBUF [get_cells -quiet -hier -filter {REF_NAME == IOBUF && NAME =~ "*spi_flash_sd*1*"}]
}
set SD1_IOBUF [lindex $SD1_IOBUF 0]

set SD1_PIN_IO     [lindex [get_pins -quiet -of_objects $SD1_IOBUF -filter {REF_PIN_NAME=="IO"}] 0]
set SD1_NET_IO_OLD [lindex [get_nets -quiet -of_objects $SD1_PIN_IO] 0]
disconnect_net -net $SD1_NET_IO_OLD -objects $SD1_PIN_IO
connect_net -hier -net $NET_SD1_PORT -objects [list $SD1_PIN_IO]

# SCK IOBUF modifications
set SCK_IOBUF [get_cells -quiet -hier -filter {REF_NAME == IOBUF && NAME =~ "*pad_spi_flash_sck*"}]
if {[llength $SCK_IOBUF] == 0} {
  set SCK_IOBUF [get_cells -quiet -hier -filter {REF_NAME == IOBUF && NAME =~ "*spi_flash_sck*"}]
}
set SCK_IOBUF [lindex $SCK_IOBUF 0]

set SCK_PIN_IO     [lindex [get_pins -quiet -of_objects $SCK_IOBUF -filter {REF_PIN_NAME=="IO"}] 0]
set SCK_NET_IO_OLD [lindex [get_nets -quiet -of_objects $SCK_PIN_IO] 0]
disconnect_net -net $SCK_NET_IO_OLD -objects $SCK_PIN_IO
connect_net -hier -net $NET_SCK_PORT -objects [list $SCK_PIN_IO]

set SCK_PIN_I     [lindex [get_pins -quiet -of_objects $SCK_IOBUF -filter {REF_PIN_NAME=="I"}] 0]
set SCK_NET_I_OLD [lindex [get_nets -quiet -of_objects $SCK_PIN_I] 0]
disconnect_net -net $SCK_NET_I_OLD -objects $SCK_PIN_I

create_net SCK_ECO_I
create_cell -reference LUT3 SCK_LUTI
set_property INIT 8'hCA [get_cells SCK_LUTI]
connect_net -hier -net $SCK_NET_I_OLD -objects [list [get_pins SCK_LUTI/I0]]
connect_net -hier -net $PS_SCK        -objects [list [get_pins SCK_LUTI/I1]]
connect_net -hier -net $SEL           -objects [list [get_pins SCK_LUTI/I2]]
connect_net -hier -net SCK_ECO_I      -objects [list [get_pins SCK_LUTI/O] $SCK_PIN_I]

set SCK_PIN_T     [lindex [get_pins -quiet -of_objects $SCK_IOBUF -filter {REF_PIN_NAME=="T"}] 0]
set SCK_NET_T_OLD [lindex [get_nets -quiet -of_objects $SCK_PIN_T] 0]
disconnect_net -net $SCK_NET_T_OLD -objects $SCK_PIN_T

create_net SCK_ECO_T
create_cell -reference LUT2 SCK_LUTT
set_property INIT 4'h8 [get_cells SCK_LUTT]
connect_net -hier -net $SCK_NET_T_OLD -objects [list [get_pins SCK_LUTT/I0]]
connect_net -hier -net $SEL           -objects [list [get_pins SCK_LUTT/I1]]
connect_net -hier -net SCK_ECO_T      -objects [list [get_pins SCK_LUTT/O] $SCK_PIN_T]

# CS IOBUF modifications
set CS_IOBUF [get_cells -quiet -hier -filter {REF_NAME == IOBUF && NAME =~ "*pad_spi_flash_cs*"}]
if {[llength $CS_IOBUF] == 0} {
  set CS_IOBUF [get_cells -quiet -hier -filter {REF_NAME == IOBUF && NAME =~ "*spi_flash_csb*"}]
}
set CS_IOBUF [lindex $CS_IOBUF 0]

set CS_PIN_IO     [lindex [get_pins -quiet -of_objects $CS_IOBUF -filter {REF_PIN_NAME=="IO"}] 0]
set CS_NET_IO_OLD [lindex [get_nets -quiet -of_objects $CS_PIN_IO] 0]
disconnect_net -net $CS_NET_IO_OLD -objects $CS_PIN_IO
connect_net -hier -net $NET_CS_PORT -objects [list $CS_PIN_IO]

set CS_PIN_I     [lindex [get_pins -quiet -of_objects $CS_IOBUF -filter {REF_PIN_NAME=="I"}] 0]
set CS_NET_I_OLD [lindex [get_nets -quiet -of_objects $CS_PIN_I] 0]
disconnect_net -net $CS_NET_I_OLD -objects $CS_PIN_I

create_net CS_ECO_I
create_cell -reference LUT3 CS_LUTI
set_property INIT 8'hCA [get_cells CS_LUTI]
connect_net -hier -net $CS_NET_I_OLD -objects [list [get_pins CS_LUTI/I0]]
connect_net -hier -net $PS_CS        -objects [list [get_pins CS_LUTI/I1]]
connect_net -hier -net $SEL          -objects [list [get_pins CS_LUTI/I2]]
connect_net -hier -net CS_ECO_I      -objects [list [get_pins CS_LUTI/O] $CS_PIN_I]

set CS_PIN_T     [lindex [get_pins -quiet -of_objects $CS_IOBUF -filter {REF_PIN_NAME=="T"}] 0]
set CS_NET_T_OLD [lindex [get_nets -quiet -of_objects $CS_PIN_T] 0]
disconnect_net -net $CS_NET_T_OLD -objects $CS_PIN_T

create_net CS_ECO_T
create_cell -reference LUT2 CS_LUTT
set_property INIT 4'h8 [get_cells CS_LUTT]
connect_net -hier -net $CS_NET_T_OLD -objects [list [get_pins CS_LUTT/I0]]
connect_net -hier -net $SEL          -objects [list [get_pins CS_LUTT/I1]]
connect_net -hier -net CS_ECO_T      -objects [list [get_pins CS_LUTT/O] $CS_PIN_T]

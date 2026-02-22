### JTAG Constraints
set_max_delay -through [get_nets -filter NAME=~\"*async*\" -of_objects [get_cells -hier -filter {REF_NAME =~ cdc_2phase_src* || ORIG_REF_NAME =~ cdc_2phase_src*}]] 20.000
set_false_path -hold -through [get_nets -filter NAME=~\"*async*\" -of_objects [get_cells -hier -filter {REF_NAME =~ cdc_2phase_src* || ORIG_REF_NAME =~ cdc_2phase_src*}]]

# Hold and max delay on 4 phases


foreach cell [get_cells -hier -filter {REF_NAME == cdc_4phase_src || ORIG_REF_NAME == cdc_4phase_src}] {
set_max_delay -through [get_nets -filter {NAME=~"*data_src_q*"} null/*] 20.000
set_false_path -hold -through [get_nets -filter {NAME=~"*data_src_q*"} null/*]
set_max_delay -through [get_nets -filter {NAME=~"*req_src_q*"} null/*] 20.000
set_false_path -hold -through [get_nets -filter {NAME=~"*req_src_q*"} null/*]
}


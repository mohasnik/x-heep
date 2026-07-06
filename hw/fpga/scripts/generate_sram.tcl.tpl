% for num_words in xheep.memory_ss().iter_bank_numwords():

set ipName xilinx_mem_gen_${num_words}

% if target=="vpk180":
create_ip \\

  -name emb_mem_gen \\
  
  -vendor xilinx.com \\
  
  -library ip \\
  
  -version 1.0 \\
  
  -module_name $ipName

set_property -dict [list \\

  CONFIG.USE_MEMORY_BLOCK {Stand_Alone} \\
  
  CONFIG.MEMORY_TYPE {Single_Port_RAM} \\
  
  CONFIG.ENABLE_32BIT_ADDRESS {false} \\
  
  CONFIG.MEMORY_DEPTH {${num_words}} \\
  
  CONFIG.WRITE_DATA_WIDTH_A {32} \\
  
  CONFIG.READ_DATA_WIDTH_A {32} \\
  
  CONFIG.ENABLE_BYTE_WRITES_A {true} \\
  
  CONFIG.BYTE_WRITE_WIDTH_A {8} \\
  
  CONFIG.WRITE_MODE_A {WRITE_FIRST} \\
  
  CONFIG.READ_LATENCY_A {1} \\
  
  CONFIG.ALGORITHM {Minimum_Area} \\
  
  CONFIG.MEMORY_PRIMITIVE {AUTO} \\
  
] [get_ips $ipName]

% else :

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $ipName
set_property -dict [list CONFIG.Enable_32bit_Address {false} \\

                        CONFIG.Use_Byte_Write_Enable {true}  \\

                        CONFIG.Byte_Size {8}  \\

                        CONFIG.Algorithm {Minimum_Area}  \\

                        CONFIG.Primitive {2kx9}  \\

                        CONFIG.Write_Width_A {32}  \\

                        CONFIG.Write_Depth_A {${num_words}}  \\

                        CONFIG.Read_Width_A {32}  \\

                        CONFIG.Enable_A {Use_ENA_Pin}  \\

                        CONFIG.Write_Width_B {32}  \\

                        CONFIG.Read_Width_B {32}  \\

                        CONFIG.Register_PortA_Output_of_Memory_Primitives {false}  \\

                        CONFIG.Use_RSTA_Pin {false}  \\

                        CONFIG.EN_SAFETY_CKT {false}] [get_ips $ipName]


% endif
#
generate_target {instantiation_template} [get_ips $ipName]

#export_ip_user_files -of_objects [get_ips $ipName] -no_script -sync -force -quiet

create_ip_run [get_ips $ipName]

% endfor

<%ips = ""
for num_words in xheep.memory_ss().iter_bank_numwords():
    ips += f" xilinx_mem_gen_{num_words}_synth_1"%>
launch_runs -jobs 8 ${ips}

% for num_words in xheep.memory_ss().iter_bank_numwords():
wait_on_run xilinx_mem_gen_${num_words}_synth_1
% endfor

create_project -force aes_fpga ./fpga/vivado_proj -part xc7a35tcpg236-1
add_files [glob rtl/crypto/*.v rtl/peripheral/*.v rtl/top/*.v fpga/aes_soc_fpga.v]
add_files -fileset constrs_1 fpga/basys3.xdc
set_property top aes_soc_fpga [current_fileset]
update_compile_order -fileset sources_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
puts "BITSTREAM READY"

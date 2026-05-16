add_wave -radix unsigned tb_inst_mem/intf/inst_addr
add_wave_divider
add_wave -radix hex tb_inst_mem/intf/inst
add_wave_divider
add_wave -radix hex tb_inst_mem/dut/inst_rom

run all

write_xsim_coverage

exit

add_wave tb_reg_file/clk
add_wave_divider
add_wave tb_reg_file/intf/write_en
add_wave_divider
add_wave -radix unsigned tb_reg_file/intf/read_addr_1
add_wave -radix unsigned tb_reg_file/intf/read_addr_2
add_wave -radix unsigned tb_reg_file/intf/write_addr
add_wave -radix hex tb_reg_file/intf/write_data
add_wave_divider
add_wave -radix hex tb_reg_file/intf/read_data_1
add_wave -radix hex tb_reg_file/intf/read_data_2
add_wave_divider
add_wave -radix hex tb_reg_file/dut/reg_file

run all

write_xsim_coverage

exit



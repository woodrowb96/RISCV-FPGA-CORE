add_wave tb_register_file/clk
add_wave_divider
add_wave tb_register_file/intf/wr_en
add_wave_divider
add_wave -radix unsigned tb_register_file/intf/rd_reg_1
add_wave -radix unsigned tb_register_file/intf/rd_reg_2
add_wave -radix unsigned tb_register_file/intf/wr_reg
add_wave -radix hex tb_register_file/intf/wr_data
add_wave_divider
add_wave -radix hex tb_register_file/intf/rd_data_1
add_wave -radix hex tb_register_file/intf/rd_data_2
add_wave_divider
add_wave -radix hex tb_register_file/dut/reg_file

run all

write_xsim_coverage
export_xsim_coverage -output_dir ./coverage_reports/tb_reg_file

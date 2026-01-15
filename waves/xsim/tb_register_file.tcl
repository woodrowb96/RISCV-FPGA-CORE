add_wave tb_register_file/clk
add_wave_divider
add_wave tb_register_file/wr_en
add_wave_divider
add_wave -radix unsigned tb_register_file/rd_reg_1
add_wave -radix unsigned tb_register_file/rd_reg_2
add_wave -radix unsigned tb_register_file/wr_reg
add_wave -radix hex tb_register_file/wr_data
add_wave_divider
add_wave -radix hex tb_register_file/rd_data_1
add_wave -radix hex tb_register_file/rd_data_2
add_wave_divider
add_wave -radix hex tb_register_file/dut/reg_file

run all

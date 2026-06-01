add_wave tb_id_stage/dut/clk
add_wave_divider
add_wave tb_id_stage/dut/rd_wr_en_wb
add_wave -radix hex tb_id_stage/dut/pc_if
add_wave -radix hex tb_id_stage/dut/inst_if
add_wave -radix hex tb_id_stage/dut/rd_data_wb
add_wave_divider
add_wave -radix hex tb_id_stage/dut/pc_id
add_wave -radix hex tb_id_stage/dut/rs1_data_id
add_wave -radix hex tb_id_stage/dut/rs2_data_id
add_wave -radix hex tb_id_stage/dut/imm_id

run all

write_xsim_coverage

exit

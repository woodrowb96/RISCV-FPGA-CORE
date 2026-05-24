add_wave tb_if_stage/dut/clk
add_wave tb_if_stage/dut/reset_n
add_wave_divider
add_wave tb_if_stage/dut/branch_ex
add_wave -radix unsigned tb_if_stage/dut/branch_target_ex
add_wave_divider
add_wave -radix unsigned tb_if_stage/dut/pc_if
add_wave -radix hex tb_if_stage/dut/inst_if

run all

write_xsim_coverage

exit

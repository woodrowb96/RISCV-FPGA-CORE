add_wave -radix hex tb_imm_gen/intf/inst
add_wave_divider
add_wave -radix hex tb_imm_gen/intf/imm

run all

write_xsim_coverage

exit

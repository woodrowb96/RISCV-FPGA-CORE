add_wave tb_alu/alu_op
add_wave_divider
add_wave -radix hex tb_alu/in_a
add_wave -radix hex tb_alu/in_b
add_wave_divider
add_wave -radix hex tb_alu/result
add_wave tb_alu/zero

run all

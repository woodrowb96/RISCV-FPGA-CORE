/*
      The Instruction Decode Stage for a riscv rv32i implementation.

CLK:
  - synchronous operations are synced to the posedge of the clk

CONTROL:
  - logic wr_en_wb: 1 bit wr_en
      - Controls when the reg_file is written to
      - When 1: wr_data is written into wr_reg @(posedge clk)
      - When 0: wr_data is not written

INPUT:
  - word_t inst_if: 32bit instruction from the if_stage

  - word_t wr_data_if: data which is to be written into the wr_reg
      - This signal is routed back into the ID stage from the WB stage

OUTPUT:
  - word_t rs1_data_id: data read from the rs1 source register
      - The rs1 register is parsed from bits [19:15] in the inst

  - word_t rs2_data_id: data read from the rs2 source register
      - The rs2 register is parsed from bits [24:20] in the inst

  - word_t imm_id: 32 bit immediate encoded in the instruction
*/
module id_stage
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
(
  input logic clk,

  //control
  input logic wr_en_wb,

  //input
  input word_t pc_if,
  input word_t inst_if,
  input word_t wr_data_wb,

  //output
  output word_t pc_id,
  output word_t rs1_data_id,
  output word_t rs2_data_id,
  output word_t imm_id
);

endmodule

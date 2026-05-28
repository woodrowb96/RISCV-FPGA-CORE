/*
      The Instruction Decode Stage for a riscv rv32i implementation.

CLK:
  - synchronous operations are synced to the posedge of the clk

CONTROL:
  - logic rd_wr_en_wb: 1 bit reg_file write enable
      - Controls when the reg_file is written to
      - When 1: rd_data_wb is written into the destination register @(posedge clk)
      - When 0: rd_data_wb is not written

INPUT:
  - word_t inst_if: 32bit instruction from the if_stage

  - word_t rd_data_wb: data which is to be written into the destination register
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
  input logic rd_wr_en_wb,

  //input
  input word_t pc_if,
  input word_t inst_if,
  input word_t rd_data_wb,

  //output
  output word_t pc_id,
  output word_t rs1_data_id,
  output word_t rs2_data_id,
  output word_t imm_id
);
  rf_addr_t rs1_addr;
  rf_addr_t rs2_addr;
  rf_addr_t rd_addr;

  /************** PASS THROUGHS **************/
  assign pc_id = pc_if;

  /*********** PARSE RS/RD FROM INST **********/
  assign rs1_addr = inst_if[19:15];
  assign rs2_addr = inst_if[24:20];
  assign rd_addr  = inst_if[11:7];

  /************** REG_FILE ********************/
  reg_file u_reg_file (
    .clk          (clk),
    .write_en     (rd_wr_en_wb),
    .write_addr   (rd_addr),
    .write_data   (rd_data_wb),
    .read_addr_1  (rs1_addr),
    .read_addr_2  (rs2_addr),
    .read_data_1  (rs1_data_id),
    .read_data_2  (rs2_data_id)
  );

  /*********** IMMEDIATE GENERATION **********/
  imm_gen u_imm_gen (
    .inst(inst_if),
    .imm(imm_id)
  );
endmodule

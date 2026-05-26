module ex_stage
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
(
  //control
  input alu_op_t      alu_op_id,
  input alu_src_sel_t alu_src_sel_id,
  input branch_type_t branch_type_id,

  //input
  input word_t pc_id,
  input word_t imm_id,
  input word_t rs1_data_id,
  input word_t rs2_data_id

  //output
  output logic  branch_taken_ex,
  output word_t branch_target_ex,
  output word_t alu_result_ex,
  output word_t rs2_data_ex
);
endmodule

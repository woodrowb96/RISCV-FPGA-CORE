module control
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
(
  //input
  input word_t inst_id,

  //output (id_stage control)
  output logic rd_wr_en_id,

  //output (ex_stage control)
  output alu_op_t                alu_op_id,
  output alu_src_sel_2_t         alu_src_sel_2_id,
  output branch_type_t           branch_type_id,
  output branch_target_src_sel_t branch_target_src_sel_id,

  //output (mem_stage control)
  output byte_sel_t mem_store_byte_sel_id,

  //output (wb_stage control)
  output wb_sel_t wb_sel_id
);
endmodule

module wb_stage
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
(
  //control
  input wb_sel_t wb_sel_mem,

  //input
  input word_t alu_result_mem,
  input word_t load_data_mem,

  //output
  output word_t rd_data_wb
);
endmodule

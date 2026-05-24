module mem_stage
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import rv32i_control_pkg::*;
(
  input logic clk,

  //control
  input byte_sel_t wr_sel_mem,

  //input
  input word_t alu_result_ex,
  input word_t rs2_data_ex,

  //output
  output word_t alu_result_mem,
  output word_t rd_data_mem
);
endmodule

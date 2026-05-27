module mem_stage
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
(
  input logic clk,

  //control
  input byte_sel_t mem_store_byte_sel_ex,

  //input
  input word_t alu_result_ex,
  input word_t rs2_data_ex,

  //output
  output word_t alu_result_mem,
  output word_t load_data_mem
);
  /************ PASS THROUGHS ***********/
  assign alu_result_mem = alu_result_ex;

  /************** DATA MEMORY************/
  data_mem u_data_mem (
    .clk(clk),
    .store_byte_sel(mem_store_byte_sel_ex),
    .addr(alu_result_ex),
    .store_data(rs2_data_ex),
    .load_data(load_data_mem)
  );
endmodule

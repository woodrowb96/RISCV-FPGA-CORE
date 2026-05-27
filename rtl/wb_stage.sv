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
  /********* WRITE BACK SELECT *************/
  always_comb begin
    unique case(wb_sel_mem)
      MEM: begin
        rd_data_wb = load_data_mem;
      end
      ALU: begin
        rd_data_wb = alu_result_mem;
      end
      default: begin
        rd_data_wb = 'x;
      end
    endcase
  end
endmodule

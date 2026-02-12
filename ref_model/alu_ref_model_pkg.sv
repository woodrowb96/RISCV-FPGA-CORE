package alu_ref_model_pkg;
  import riscv_32i_defs_pkg::*;

  //so we can return both expected values at the same time
  typedef struct {
    word_t result;
    logic zero;
  } expected_output;

  class alu_ref_model;

    //look at the input and calc the expected output
    function expected_output expected(alu_op_t alu_op, word_t in_a, word_t in_b);
      logic [XLEN:0] in_a_wide = {1'b0, in_a};
      logic [XLEN:0] in_b_wide = {1'b0, in_b};
      logic [XLEN:0] result_wide = '0;
      logic zero = 1'b0;

      expected_output exp;

      if(alu_op == ALU_SUB) begin
        result_wide = in_a_wide - in_b_wide;
      end
      else if(alu_op == ALU_ADD) begin
        result_wide = in_a_wide + in_b_wide;
      end
      else if(alu_op == ALU_OR) begin
        result_wide = in_a_wide | in_b_wide;
      end
      else if(alu_op == ALU_AND) begin
        result_wide = in_a_wide & in_b_wide;
      end

      if(result_wide[XLEN-1:0] == '0) begin
        zero = 1'b1;
      end

      exp.result = result_wide[XLEN-1:0];
      exp.zero = zero;

      return exp;
    endfunction
  endclass
endpackage

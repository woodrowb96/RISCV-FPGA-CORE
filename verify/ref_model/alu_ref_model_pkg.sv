package alu_ref_model_pkg;
  import riscv_32i_defs_pkg::*;
  import tb_alu_transaction_pkg::*;

  //so we can return both expected values at the same time
  typedef struct {
    word_t result;
    logic zero;
  } alu_ref_output;

  class alu_ref_model;

    function alu_ref_output predict(alu_general_trans trans);
      logic [XLEN:0] in_a_wide = {1'b0, trans.in_a};
      logic [XLEN:0] in_b_wide = {1'b0, trans.in_b};
      logic [XLEN:0] result_wide = '0;

      logic zero = 1'b0;

      if(trans.alu_op == ALU_SUB) begin
        result_wide = in_a_wide - in_b_wide;
      end
      else if(trans.alu_op == ALU_ADD) begin
        result_wide = in_a_wide + in_b_wide;
      end
      else if(trans.alu_op == ALU_OR) begin
        result_wide = in_a_wide | in_b_wide;
      end
      else if(trans.alu_op == ALU_AND) begin
        result_wide = in_a_wide & in_b_wide;
      end

      if(result_wide[XLEN-1:0] == '0) begin
        zero = 1'b1;
      end

      return '{result_wide[XLEN-1:0], zero};
    endfunction
  endclass
endpackage

package alu_ref_model_pkg;
  typedef struct {
    logic [31:0] result;
    logic zero;
  } expected_output;

  class alu_ref_model;
    function expected_output expected(logic [3:0] alu_op,
                                      logic [31:0] in_a,
                                      logic [31:0] in_b);
      logic [32:0] in_a_wide = {1'b0, in_a};
      logic [32:0] in_b_wide = {1'b0, in_b};
      logic [32:0] result_wide = '0;
      logic zero = 1'b0;

      expected_output exp;

      if(alu_op == 4'b0110) begin
        result_wide = in_a_wide - in_b_wide;
      end
      else if(alu_op == 4'b0010) begin
        result_wide = in_a_wide + in_b_wide;
      end
      else if(alu_op == 4'b0001) begin
        result_wide = in_a_wide | in_b_wide;
      end
      else if(alu_op == 4'b0000) begin
        result_wide = in_a_wide & in_b_wide;
      end

      if(result_wide[31:0] == '0) begin
        zero = 1'b1;
      end

      exp.result = result_wide[31:0];
      exp.zero = zero;

      return exp;
    endfunction
  endclass
endpackage

class alu_coverage extends uvm_object;
  `uvm_object_utils(alu_coverage);

  alu_seq_item item;

  function new(string name = "alu_coverage");
    super.new(name);
    this.cg = new();
  endfunction

  function void sample(alu_seq_item item);
    this.item = item;
    cg.sample();
  endfunction

  function void print_coverage_report();
    real total = cg.get_inst_coverage();
    $display("\n========================================");
    $display("***   alu_coverage: %6.2f%%        ***", total);
    $display("========================================");
    if (total < 100.0) begin
      $display("  alu_op:               %6.2f%%", cg.alu_op.get_coverage());
      $display("  zero_flag:            %6.2f%%", cg.zero_flag.get_coverage());
      $display("  alu_op_x_zero_flag:   %6.2f%%", cg.alu_op_x_zero_flag.get_coverage());
      $display("  in_a_log_op:          %6.2f%%", cg.in_a_log_op.get_coverage());
      $display("  in_b_log_op:          %6.2f%%", cg.in_b_log_op.get_coverage());
      $display("  in_a_x_in_b_and:      %6.2f%%", cg.in_a_x_in_b_and.get_coverage());
      $display("  in_a_x_in_b_or:       %6.2f%%", cg.in_a_x_in_b_or.get_coverage());
      $display("  in_a_add_op:          %6.2f%%", cg.in_a_add_op.get_coverage());
      $display("  in_b_add_op:          %6.2f%%", cg.in_b_add_op.get_coverage());
      $display("  in_a_x_in_b_add:      %6.2f%%", cg.in_a_x_in_b_add.get_coverage());
      $display("  add_overflow:         %6.2f%%", cg.add_overflow.get_coverage());
      $display("  in_a_sub_op:          %6.2f%%", cg.in_a_sub_op.get_coverage());
      $display("  in_b_sub_op:          %6.2f%%", cg.in_b_sub_op.get_coverage());
      $display("  in_a_x_in_b_sub:      %6.2f%%", cg.in_a_x_in_b_sub.get_coverage());
      $display("  sub_overflow:         %6.2f%%", cg.sub_overflow.get_coverage());
      $display("========================================\n");
    end
    else begin
      $display("");
    end
  endfunction

  //Treating in_a and in_b as unsigned 32 bit nums,
  //compute a wide result, check if the wide msb is set
  function automatic bit detect_add_overflow(word_t in_a, word_t in_b);
    logic [XLEN:0] result_wide = {1'b0, in_a} + {1'b0, in_b};
    return result_wide[XLEN];
  endfunction

  //Treating both nums as signed 2s compliment, an overflow happens when:
  //  - in_a and in_b are opposite signs AND
  //  - result has a diff sign than in_a
  function automatic bit detect_sub_overflow(word_t in_a, word_t in_b);
    word_t result = in_a - in_b;
    return (in_a[XLEN-1] != in_b[XLEN-1]) && (result[XLEN-1] != in_a[XLEN-1]);
  endfunction

  covergroup cg;
    /*================= ALU_OP COVERAGE ====================*/

    alu_op: coverpoint item.alu_op {
      bins op_and = {ALU_AND};
      bins op_or  = {ALU_OR};
      bins op_add = {ALU_ADD};
      bins op_sub = {ALU_SUB};
      bins invalid = default;
    }


    /*================= ZERO FLAG  COVERAGE ===================*/
    zero_flag: coverpoint item.zero{
      bins set   = {1'b1};
      bins unset = {1'b0};
    }

    //we want zeros and non_zeros with each op
    alu_op_x_zero_flag: cross alu_op, zero_flag;


    /*============= LOGICAL OPERATIONS COVERAGE ===============*/

    //we want to hit the following corners
    in_a_log_op: coverpoint item.in_a
      iff (item.alu_op inside {ALU_AND, ALU_OR}) {
        bins all_zero    = {WORD_ALL_ZEROS};
        bins alt_ones_55 = {WORD_ALT_ONES_55};
        bins alt_ones_aa = {WORD_ALT_ONES_AA};
        bins all_one     = {WORD_ALL_ONES};
        bins non_corners = default;
    }
    in_b_log_op: coverpoint item.in_b
      iff (item.alu_op inside {ALU_AND, ALU_OR}) {
        bins all_zero    = {WORD_ALL_ZEROS};
        bins alt_ones_55 = {WORD_ALT_ONES_55};
        bins alt_ones_aa = {WORD_ALT_ONES_AA};
        bins all_one     = {WORD_ALL_ONES};
        bins non_corners = default;
    }

    //We want to cover all combos of corner cases for each logical op
    in_a_x_in_b_and: cross in_a_log_op, in_b_log_op
      iff (item.alu_op == ALU_AND);
    in_a_x_in_b_or: cross in_a_log_op, in_b_log_op
      iff (item.alu_op == ALU_OR);


    /*================== ADD OPERATION COVERAGE ===================*/

    //we want to hit the following corners values/ranges for both inputs
    in_a_add_op: coverpoint item.in_a
      iff (item.alu_op == ALU_ADD) {
        bins zero             = {WORD_UNSIGNED_ZERO};
        bins one              = {WORD_UNSIGNED_ONE};
        bins max_unsigned     = {WORD_MAX_UNSIGNED};
        bins non_corners_low  = {[WORD_UNSIGNED_ZERO + 1       : UNSIGNED_LOWER_THIRD]};
        bins non_corners_med  = {[UNSIGNED_LOWER_THIRD + 1     : UNSIGNED_LOWER_TWO_THIRD]};
        bins non_corners_high = {[UNSIGNED_LOWER_TWO_THIRD + 1 : WORD_MAX_UNSIGNED - 1]};
      }
    in_b_add_op: coverpoint item.in_b
      iff (item.alu_op == ALU_ADD) {
        bins zero             = {WORD_UNSIGNED_ZERO};
        bins one              = {WORD_UNSIGNED_ONE};
        bins max_unsigned     = {WORD_MAX_UNSIGNED};
        bins non_corners_low  = {[WORD_UNSIGNED_ZERO + 1       : UNSIGNED_LOWER_THIRD]};
        bins non_corners_med  = {[UNSIGNED_LOWER_THIRD + 1     : UNSIGNED_LOWER_TWO_THIRD]};
        bins non_corners_high = {[UNSIGNED_LOWER_TWO_THIRD + 1 : WORD_MAX_UNSIGNED - 1]};
      }

    //we want to cover all combos of corners
    in_a_x_in_b_add: cross in_a_add_op, in_b_add_op
      iff (item.alu_op == ALU_ADD);

    //we want to cover both overflowing and not overflowing during an add_op
    add_overflow: coverpoint detect_add_overflow(item.in_a, item.in_b) 
      iff (item.alu_op == ALU_ADD){
          bins yes = {1};
          bins no = {0};
      }


    /*================== SUB OPERATION COVERAGE ========================*/

    //we want to hit the following corners values/ranges for both inputs
    in_a_sub_op: coverpoint item.in_a
      iff (item.alu_op == ALU_SUB) {
        bins zero                 = {WORD_SIGNED_ZERO};
        bins signed_pos_one       = {WORD_SIGNED_POS_ONE};
        bins signed_neg_one       = {WORD_SIGNED_NEG_ONE};
        bins max_signed_pos       = {WORD_MAX_SIGNED_POS};
        bins min_signed_neg       = {WORD_MIN_SIGNED_NEG};
        bins non_corners_low_pos  = {[WORD_SIGNED_POS_ONE   + 1 : SIGNED_POS_LOWER_HALF]};
        bins non_corners_high_pos = {[SIGNED_POS_LOWER_HALF + 1 : WORD_MAX_SIGNED_POS   - 1]};
        bins non_corners_high_neg = {[SIGNED_NEG_LOWER_HALF     : WORD_SIGNED_NEG_ONE   - 1]};
        bins non_corners_low_neg  = {[WORD_MIN_SIGNED_NEG   + 1 : SIGNED_NEG_LOWER_HALF - 1]};
      }
    in_b_sub_op: coverpoint item.in_b
      iff (item.alu_op == ALU_SUB) {
        bins zero                 = {WORD_SIGNED_ZERO};
        bins signed_pos_one       = {WORD_SIGNED_POS_ONE};
        bins signed_neg_one       = {WORD_SIGNED_NEG_ONE};
        bins max_signed_pos       = {WORD_MAX_SIGNED_POS};
        bins min_signed_neg       = {WORD_MIN_SIGNED_NEG};
        bins non_corners_low_pos  = {[WORD_SIGNED_POS_ONE   + 1 : SIGNED_POS_LOWER_HALF]};
        bins non_corners_high_pos = {[SIGNED_POS_LOWER_HALF + 1 : WORD_MAX_SIGNED_POS   - 1]};
        bins non_corners_high_neg = {[SIGNED_NEG_LOWER_HALF     : WORD_SIGNED_NEG_ONE   - 1]};
        bins non_corners_low_neg  = {[WORD_MIN_SIGNED_NEG   + 1 : SIGNED_NEG_LOWER_HALF - 1]};
      }

    in_a_x_in_b_sub: cross in_a_sub_op, in_b_sub_op
      iff (item.alu_op == ALU_SUB);

    sub_overflow: coverpoint detect_sub_overflow(item.in_a, item.in_b)
      iff (item.alu_op == ALU_SUB){
          bins yes = {1};
          bins no = {0};
      }
  endgroup
endclass

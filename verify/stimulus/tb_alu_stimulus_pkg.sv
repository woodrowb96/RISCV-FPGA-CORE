package tb_alu_stimulus_pkg;
  import riscv_32i_defs_pkg::*;
  import tb_alu_transaction_pkg::*;

  //transaction for logical operations (and, or ...)
  class alu_logical_op_trans extends alu_trans;
    constraint logical_op_inputs {
      /******* NOTE **********/
      //I think this might be another case of a bug in xsim.
      //
      //In my range I set the ranges from ['0 + 1 to '1 - 1] (so I carve out the all 1s and all 0s cases)
      //
      // in_a dist {
      //   WORD_ALL_ZEROS                          := 3,
      //   WORD_ALT_ONES_55                        := 3,
      //   WORD_ALT_ONES_AA                        := 3,
      //   WORD_ALL_ONES                           := 3,
      //   [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1] :/ 2  //I carve out all zeros and all 1s
      // };
      //
      //I do this because when the range overlapped with those values, the
      //constraint solver only used the value 32'd1 when it selected a value
      //from the range.
      //
      //I think it might be because the range is so large and the overlaps
      //were causing issues. Maybe its too much for the solver to handle?
      //But then why dont I have to carve out the AA and 55 corners?
      //
      //I dont know it might have something to do with when the solver tries
      //to handle the extreme corners of this big range (so the range ending
      //points), and it just picks the easiest solution, which is 32'd1? maybe?
      //
      //Once again, this is either a bug in this version of xsim, or I am misunderstanding
      //how constraints work. Im still learning so it could be either, but
      //I think it might just be a bug.
      /***********************/
      in_a dist {
        WORD_ALL_ZEROS                            := 3,
        WORD_ALT_ONES_55                          := 3, //the pattern 4'h5 = 0101 repeated
        WORD_ALT_ONES_AA                          := 3, //the pattern 4'hA = 1010 repeated
        WORD_ALL_ONES                             := 3,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
      in_b dist {
        WORD_ALL_ZEROS                            := 3,
        WORD_ALT_ONES_55                          := 3, //the pattern 4'h5 = 0101 repeated
        WORD_ALT_ONES_AA                          := 3, //the pattern 4'hA = 1010 repeated
        WORD_ALL_ONES                             := 3,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
    }
  endclass

  //transaction for ADD ops
  class alu_add_op_trans extends alu_trans;
    constraint add_op { alu_op == ALU_ADD; }

    constraint add_op_inputs {
      in_a dist {
        WORD_UNSIGNED_ZERO                        := 3,
        WORD_UNSIGNED_ONE                         := 3,
        WORD_MAX_UNSIGNED                         := 3,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
      in_b dist {
        WORD_UNSIGNED_ZERO                        := 3,
        WORD_UNSIGNED_ONE                         := 3,
        WORD_MAX_UNSIGNED                         := 3,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
    }
  endclass

  //transaction for SUB ops
  class alu_sub_op_trans extends alu_trans;
    constraint sub_op { alu_op == ALU_SUB; }

    constraint sub_op_inputs {
      in_a dist {
        WORD_SIGNED_ZERO                          := 4,
        WORD_SIGNED_POS_ONE                       := 4,
        WORD_SIGNED_NEG_ONE                       := 4,
        WORD_MAX_SIGNED_POS                       := 4,
        WORD_MIN_SIGNED_NEG                       := 4,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
      in_b dist {
        WORD_SIGNED_ZERO                          := 4,
        WORD_SIGNED_POS_ONE                       := 4,
        WORD_SIGNED_NEG_ONE                       := 4,
        WORD_MAX_SIGNED_POS                       := 4,
        WORD_MIN_SIGNED_NEG                       := 4,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 2
      };
    }
  endclass
endpackage

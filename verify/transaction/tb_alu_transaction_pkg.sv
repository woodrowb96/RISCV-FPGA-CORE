package tb_alu_transaction_pkg;
  import riscv_32i_defs_pkg::*;

  class alu_general_trans;
    //output to DUT
    rand alu_op_t alu_op;
    rand bit [XLEN-1:0] in_a;
    rand bit [XLEN-1:0] in_b;

    //input from DUT
    word_t result;
    logic zero;

    /******* NOTE **********/
    //I am using the post_randomize function to manually randomize the MSB in
    //the inputs.
    //
    //I am doing this because of a possible bug in the free version of xsim.
    //When I try and use dist to get corners and non corners like this:
    //
    // in_a dist {
    //   WORD_ALL_ZEROS                          := 3,
    //   WORD_ALT_ONES_55                        := 3,
    //   WORD_ALT_ONES_AA                        := 3,
    //   WORD_ALL_ONES                           := 3,
    //   [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1] :/ 2  //MSB DOESNT GET RANDOMIZED
    // };
    //
    //The constraint solver never sets the MSB when it chooses a value in the
    //range. Bits [30:0] are fully randomized, but the MSB is never set.
    //
    //This is either a bug in this version of xsim, or I am misunderstanding
    //how constraints work. Im still learning so it could be either, but
    //I think it might just be a bug because I think the above dist should work.
    /***********************/
    function void post_randomize();
    //During post_rand manually randomize the MSB in both inputs
    //I only want to do this when the input is not one of the corners
      if(!(in_a inside {WORD_ALL_ZEROS, WORD_ALL_ONES,
                        WORD_ALT_ONES_55, WORD_ALT_ONES_AA,
                        WORD_UNSIGNED_ONE,
                        WORD_MAX_SIGNED_POS, WORD_MIN_SIGNED_NEG})) begin
        randcase
          1: in_a[XLEN-1] = 1'b0;
          1: in_a[XLEN-1] = 1'b1;
        endcase
      end

      if(!(in_b inside {WORD_ALL_ZEROS, WORD_ALL_ONES,
                        WORD_ALT_ONES_55, WORD_ALT_ONES_AA,
                        WORD_UNSIGNED_ONE,
                        WORD_MAX_SIGNED_POS, WORD_MIN_SIGNED_NEG})) begin
        randcase
          1: in_b[XLEN-1] = 1'b0;
          1: in_b[XLEN-1] = 1'b1;
        endcase
      end
    endfunction

    function void print(string msg = "");
      $display("[%s] t=%0t alu_op:%0b in_a:%0h in_b:%0h result:%0h zero:%0b",
               msg, $time, alu_op, in_a, in_b, result, zero);
    endfunction
  endclass
endpackage

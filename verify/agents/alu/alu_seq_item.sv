class alu_seq_item extends uvm_sequence_item;
  `uvm_object_utils(alu_seq_item)

  rand alu_op_t alu_op;   //control
  rand word_t   in_a;     //input
  rand word_t   in_b;
  word_t        result;   //output
  logic         zero;

  constraint valid_alu_ops {
    alu_op inside {ALU_AND, ALU_OR, ALU_ADD, ALU_SUB};
  }

  function new(string name = "alu_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf(
      "alu_op:%s | in_a=%0h in_b=%0h | result=%0h zero=%0b",
       alu_op.name(),
       in_a, in_b,
       result, zero);
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    alu_seq_item rhs_;

    if (!$cast(rhs_, rhs))
      return 0;

    return (result == rhs_.result &&
            zero   == rhs_.zero);
  endfunction

  /******** NOTE ********/
  //Post_randomizing the MSB is a workaround for a Vivado bug.
  /***********************/
  function void post_randomize();
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
endclass

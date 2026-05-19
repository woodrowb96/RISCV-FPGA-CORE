class imm_gen_seq_item extends uvm_sequence_item;
  `uvm_object_utils(imm_gen_seq_item)

  rand word_t inst;   //input
  word_t      imm;    //output

  constraint valid_opcodes {
    inst[6:0] inside {
      OP_REG, OP_IMM, OP_LOAD, OP_STORE, OP_BRANCH, OP_LUI, OP_AUIPC, OP_JAL, OP_JALR
    };
  }

  function new(string name = "imm_gen_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    opcode_t opcode = opcode_t'(inst[6:0]);
    return $sformatf(
      "inst:%0h | imm=%0h | opcode=%s",
       inst, imm, opcode.name());
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    imm_gen_seq_item rhs_;

    if (!$cast(rhs_, rhs))
      return 0;

    return (imm === rhs_.imm);
  endfunction

  /******** NOTE ********/
  //Post_randomizing the MSB is a workaround for a Vivado bug.
  //  - 32 bit signals do not get their MSB randomized by the
  //    constraint solver.
  /***********************/
  function void post_randomize();
    randcase
      1: inst[XLEN-1] = 1'b0;
      1: inst[XLEN-1] = 1'b1;
    endcase
  endfunction
endclass

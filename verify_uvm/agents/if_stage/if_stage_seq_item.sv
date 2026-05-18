class if_stage_seq_item extends uvm_sequence_item;
  `uvm_object_utils(if_stage_seq_item)

  rand logic branch;          //control
  rand word_t branch_target;  //input
  word_t pc;                  //output
  word_t inst;

  constraint word_aligned_branch_target {
    branch_target[1:0] == 2'b00;
  }
  constraint legal_branch_target_range {
    branch_target inside { [INST_MEM_FIRST_ADDR : INST_MEM_LAST_ADDR] };
  }

  function new(string name = "if_stage_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf(
      "branch:%b | branch_target=%d | pc=%d inst=%h",
       branch, branch_target, pc, inst);
  endfunction

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    if_stage_seq_item rhs_;

    if (!$cast(rhs_, rhs))
      return 0;

    return (pc   === rhs_.pc &&
            inst === rhs_.inst);
  endfunction
endclass

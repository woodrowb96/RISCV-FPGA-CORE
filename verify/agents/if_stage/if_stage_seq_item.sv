class if_stage_seq_item extends uvm_sequence_item;
  `uvm_object_utils(if_stage_seq_item)

  rand logic branch_taken_ex;    //control
  rand word_t branch_target_ex;  //input
  word_t pc_if;                  //output
  word_t inst_if;

  constraint word_aligned_branch_target {
    branch_target_ex[1:0] == 2'b00;
  }
  constraint legal_branch_target_range {
    branch_target_ex inside { [INST_MEM_FIRST_ADDR : INST_MEM_LAST_ADDR] };
  }

  function new(string name = "if_stage_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf(
      "branch_taken_ex:%b | branch_target_ex=%d | pc_if=%d inst_if=%h",
       branch_taken_ex, branch_target_ex, pc_if, inst_if);
  endfunction

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    if_stage_seq_item rhs_;

    if (!$cast(rhs_, rhs))
      return 0;

    return (pc_if   === rhs_.pc_if &&
            inst_if === rhs_.inst_if);
  endfunction
endclass

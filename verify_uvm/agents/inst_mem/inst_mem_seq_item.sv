class inst_mem_seq_item extends uvm_sequence_item;
  `uvm_object_utils(inst_mem_seq_item)

  rand word_t inst_addr;  //input
  word_t      inst;       //output

  //these are named so misaligned and oob sequences can disable them
  //via constraint_mode(0)
  constraint legal_addr_range {
    inst_addr inside { [INST_MEM_FIRST_ADDR : INST_MEM_LAST_ADDR] };
  }
  constraint word_aligned {
    inst_addr[1:0] == 2'b00;
  }

  function new(string name = "inst_mem_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf(
      "inst_addr=%0d | inst=%h",
        inst_addr, inst);
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    inst_mem_seq_item rhs_;

    if (!$cast(rhs_, rhs))
      return 0;

    return (inst === rhs_.inst);
  endfunction
endclass

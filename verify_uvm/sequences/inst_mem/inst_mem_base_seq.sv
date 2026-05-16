class inst_mem_base_seq extends uvm_sequence #(inst_mem_seq_item);
  `uvm_object_utils(inst_mem_base_seq)

  int seq_length = 0;

  function new(string name = "inst_mem_base_seq");
    super.new(name);
  endfunction
endclass

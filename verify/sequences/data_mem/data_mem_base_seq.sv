class data_mem_base_seq extends uvm_sequence #(data_mem_seq_item);
  `uvm_object_utils(data_mem_base_seq)

  int seq_length = 0;

  function new(string name = "data_mem_base_seq");
    super.new(name);
  endfunction
endclass

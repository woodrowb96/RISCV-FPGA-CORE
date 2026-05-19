class reg_file_base_seq extends uvm_sequence #(reg_file_seq_item);
  `uvm_object_utils(reg_file_base_seq)

  int seq_length = 0;

  function new(string name = "reg_file_base_seq");
    super.new(name);
  endfunction
endclass

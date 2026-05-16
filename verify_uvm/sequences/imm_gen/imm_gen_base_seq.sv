class imm_gen_base_seq extends uvm_sequence #(imm_gen_seq_item);
  `uvm_object_utils(imm_gen_base_seq)

  int seq_length = 0;

  function new(string name = "imm_gen_base_seq");
    super.new(name);
  endfunction
endclass

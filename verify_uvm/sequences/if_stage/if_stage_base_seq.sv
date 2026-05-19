class if_stage_base_seq extends uvm_sequence #(if_stage_seq_item);
  `uvm_object_utils(if_stage_base_seq)

  int seq_length = 0;

  function new(string name = "if_stage_base_seq");
    super.new(name);
  endfunction
endclass

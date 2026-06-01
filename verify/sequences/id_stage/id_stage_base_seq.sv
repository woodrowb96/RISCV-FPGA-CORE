class id_stage_base_seq extends uvm_sequence #(id_stage_seq_item);
  `uvm_object_utils(id_stage_base_seq)

  int seq_length = 0;

  function new(string name = "id_stage_base_seq");
    super.new(name);
  endfunction
endclass

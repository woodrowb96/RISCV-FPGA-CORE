class lut_ram_base_seq extends uvm_sequence #(lut_ram_seq_item);
  `uvm_object_utils(lut_ram_base_seq)

  int seq_length = 0;

  function new(string name = "lut_ram_base_seq");
    super.new(name);
  endfunction
endclass

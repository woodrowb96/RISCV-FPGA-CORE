class inst_mem_misaligned_test extends inst_mem_base_test;
  `uvm_component_utils(inst_mem_misaligned_test)

  function new(string name = "inst_mem_misaligned_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seq = inst_mem_misaligned_seq::type_id::create("seq");
    seq.seq_length = 10;
  endfunction
endclass

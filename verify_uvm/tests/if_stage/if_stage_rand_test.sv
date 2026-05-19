class if_stage_rand_test extends if_stage_base_test;
  `uvm_component_utils(if_stage_rand_test)

  function new(string name = "if_stage_rand_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seq = if_stage_rand_seq::type_id::create("seq");
    seq.seq_length = 200;
  endfunction
endclass

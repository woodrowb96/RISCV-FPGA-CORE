class id_stage_rand_test extends id_stage_base_test;
  `uvm_component_utils(id_stage_rand_test)

  function new(string name = "id_stage_rand_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seq = id_stage_rand_seq::type_id::create("seq");
    seq.seq_length = 1000;
  endfunction
endclass

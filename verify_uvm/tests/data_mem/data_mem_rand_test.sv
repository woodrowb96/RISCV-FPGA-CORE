class data_mem_rand_test extends data_mem_base_test;
  `uvm_component_utils(data_mem_rand_test)

  function new(string name = "data_mem_rand_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seq = data_mem_rand_seq::type_id::create("seq");
    seq.seq_length = 1500;
  endfunction
endclass

class reg_file_rand_test extends reg_file_base_test;
  `uvm_component_utils(reg_file_rand_test)

  function new(string name = "reg_file_rand_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seq = reg_file_rand_seq::type_id::create("seq");
    seq.seq_length = 10;
  endfunction
endclass

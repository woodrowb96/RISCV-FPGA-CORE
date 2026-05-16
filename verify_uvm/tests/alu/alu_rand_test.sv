class alu_rand_test extends alu_base_test;
  `uvm_component_utils(alu_rand_test)

  function new(string name = "alu_rand_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seq = alu_rand_seq::type_id::create("seq");
    seq.seq_length = 1250;
  endfunction
endclass

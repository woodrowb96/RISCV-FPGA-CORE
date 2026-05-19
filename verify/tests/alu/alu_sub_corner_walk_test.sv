class alu_sub_corner_walk_test extends alu_base_test;
  `uvm_component_utils(alu_sub_corner_walk_test)

  function new(string name = "alu_sub_corner_walk_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seq = alu_sub_corner_walk_seq::type_id::create("seq");
  endfunction
endclass

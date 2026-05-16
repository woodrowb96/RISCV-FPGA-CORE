class reg_file_coverage_subscriber extends uvm_subscriber #(reg_file_seq_item);
  `uvm_component_utils(reg_file_coverage_subscriber)

  reg_file_coverage coverage;

  function new(string name = "reg_file_coverage_subscriber", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    coverage = reg_file_coverage::type_id::create("coverage");
  endfunction

  virtual function void write(reg_file_seq_item item);
    `uvm_info("COV_SUB" , $sformatf("Collecting coverage on item:%s",
                                    item.convert2string()), UVM_HIGH)

    coverage.sample(item);
  endfunction

  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    coverage.print_coverage_report();
  endfunction
endclass

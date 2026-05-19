class inst_mem_env extends uvm_env;
  `uvm_component_utils(inst_mem_env)

  inst_mem_agent               agn;
  inst_mem_scoreboard          scb;
  inst_mem_coverage_subscriber cov_sub;

  function new(string name = "inst_mem_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agn     = inst_mem_agent::type_id::create("agn", this);
    scb     = inst_mem_scoreboard::type_id::create("scb", this);
    cov_sub = inst_mem_coverage_subscriber::type_id::create("cov_sub", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agn.mon.observed_ap.connect(scb.observed_imp);
    scb.coverage_ap.connect(cov_sub.analysis_export);
  endfunction
endclass

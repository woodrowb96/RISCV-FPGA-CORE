class data_mem_env extends uvm_env;
  `uvm_component_utils(data_mem_env)

  data_mem_agent               agn;
  data_mem_scoreboard          scb;
  data_mem_coverage_subscriber cov_sub;

  function new(string name = "data_mem_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agn     = data_mem_agent::type_id::create("agn", this);
    scb     = data_mem_scoreboard::type_id::create("scb", this);
    cov_sub = data_mem_coverage_subscriber::type_id::create("cov_sub", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agn.mon.observed_ap.connect(scb.observed_imp);
    scb.coverage_ap.connect(cov_sub.analysis_export);
  endfunction
endclass

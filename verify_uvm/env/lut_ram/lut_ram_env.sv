class lut_ram_env extends uvm_env;
  `uvm_component_utils(lut_ram_env)

  lut_ram_agent               agn;
  lut_ram_scoreboard          scb;
  lut_ram_coverage_subscriber cov_sub;

  function new(string name = "lut_ram_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agn     = lut_ram_agent::type_id::create("agn", this);
    scb     = lut_ram_scoreboard::type_id::create("scb", this);
    cov_sub = lut_ram_coverage_subscriber::type_id::create("cov_sub", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agn.mon.observed_ap.connect(scb.observed_imp);
    scb.coverage_ap.connect(cov_sub.analysis_export);
  endfunction
endclass

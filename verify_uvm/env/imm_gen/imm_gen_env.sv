class imm_gen_env extends uvm_env;
  `uvm_component_utils(imm_gen_env)

  imm_gen_agent               agn;
  imm_gen_scoreboard          scb;
  imm_gen_coverage_subscriber cov_sub;

  function new(string name = "imm_gen_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agn     = imm_gen_agent::type_id::create("agn", this);
    scb     = imm_gen_scoreboard::type_id::create("scb", this);
    cov_sub = imm_gen_coverage_subscriber::type_id::create("cov_sub", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agn.mon.observed_ap.connect(scb.observed_imp);
    scb.coverage_ap.connect(cov_sub.analysis_export);
  endfunction
endclass

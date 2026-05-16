class imm_gen_env extends uvm_env;
  `uvm_component_utils(imm_gen_env)

  imm_gen_agent      agn;
  imm_gen_scoreboard scb;

  function new(string name = "imm_gen_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agn = imm_gen_agent::type_id::create("agn", this);
    scb = imm_gen_scoreboard::type_id::create("scb", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agn.mon.observed_ap.connect(scb.observed_imp);
  endfunction
endclass

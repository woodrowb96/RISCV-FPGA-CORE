class alu_env extends uvm_env;
  `uvm_component_utils(alu_env)

  alu_agent      agn;
  alu_scoreboard scb;

  function new(string name = "alu_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agn = alu_agent::type_id::create("agn", this);
    scb = alu_scoreboard::type_id::create("scb", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agn.mon.observed_ap.connect(scb.observed_imp);
  endfunction
endclass

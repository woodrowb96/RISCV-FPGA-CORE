class reg_file_env extends uvm_env;
  `uvm_component_utils(reg_file_env)

  reg_file_agent      agn;
  reg_file_scoreboard scb;

  function new(string name = "reg_file_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agn = reg_file_agent::type_id::create("agn", this);
    scb = reg_file_scoreboard::type_id::create("scb", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agn.mon.observed_ap.connect(scb.observed_imp);
  endfunction
endclass

class if_stage_monitor extends uvm_monitor;
  `uvm_component_utils(if_stage_monitor)

  virtual if_stage_intf if_vif;
  virtual reset_intf    rst_vif;
  uvm_analysis_port #(if_stage_seq_item) observed_ap;

  function new(string name = "if_stage_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual if_stage_intf)::get(this, "", "if_stage_vif", if_vif)) begin
      `uvm_fatal("MON", "could not get if_stage vif");
    end

    if(!uvm_config_db#(virtual reset_intf)::get(this, "", "reset_vif", rst_vif)) begin
      `uvm_fatal("MON", "could not get reset vif");
    end

    observed_ap = new("observed_ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    if_stage_seq_item item;
    super.run_phase(phase);

  endtask
endclass

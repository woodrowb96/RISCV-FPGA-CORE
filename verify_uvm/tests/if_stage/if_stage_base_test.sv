class if_stage_base_test extends uvm_test;
  `uvm_component_utils(if_stage_base_test)

  virtual if_stage_intf if_vif;
  virtual reset_intf    rst_vif;
  if_stage_env          env;
  if_stage_base_seq     seq;

  function new(string name = "if_stage_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = if_stage_env::type_id::create("env", this);

    if(!uvm_config_db#(virtual if_stage_intf)::get(this, "", "if_stage_vif", if_vif))
      `uvm_fatal("TEST", "Could not get if_vif")
  
    if(!uvm_config_db#(virtual reset_intf)::get(this, "", "reset_vif", rst_vif))
      `uvm_fatal("TEST", "Could not get rst_vif")

    uvm_config_db#(virtual if_stage_intf)::set(this, "env.agn.*", "if_stage_vif", if_vif);
    uvm_config_db#(virtual reset_intf)::set(this, "env.agn.*", "reset_vif", rst_vif);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    apply_reset_n();
    if(seq == null) begin
      `uvm_fatal("BASE_TEST", "No sequence set")
    end
    else begin
      seq.start(env.agn.seqr);
    end
    repeat(INST_MEM_LATENCY + 1) @(if_vif.cb_drv);   //wait for testing to finish up

    phase.drop_objection(this);
  endtask

  virtual task apply_reset_n();
    rst_vif.reset_n = 0;
    repeat(DEFAULT_RESET_CYCLES) @(rst_vif.cb_drv);
    rst_vif.cb_drv.reset_n <= 1;
  endtask

  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    if (uvm_report_server::get_server().get_severity_count(UVM_ERROR) == 0 &&
        uvm_report_server::get_server().get_severity_count(UVM_FATAL) == 0) begin
      $display("\n========================================");
      $display("***        TEST PASSED              ***");
      $display("========================================\n");
    end else begin
      $display("\n========================================");
      $display("***        TEST FAILED              ***");
      $display("========================================\n");
    end
  endfunction
endclass

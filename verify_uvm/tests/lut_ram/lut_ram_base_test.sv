class lut_ram_base_test extends uvm_test;
  `uvm_component_utils(lut_ram_base_test)

  virtual lut_ram_intf vif;
  lut_ram_env          env;
  lut_ram_base_seq     seq;

  function new(string name = "lut_ram_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = lut_ram_env::type_id::create("env", this);

    if(!uvm_config_db#(virtual lut_ram_intf)::get(this, "", "lut_ram_vif", vif))
      `uvm_fatal("TEST", "Could not get vif")

    uvm_config_db#(virtual lut_ram_intf)::set(this, "env.agn.*", "lut_ram_vif", vif);
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
    repeat(LUT_RAM_LATENCY + 1) @(vif.cb_drv);   //wait for testing to finish up

    phase.drop_objection(this);
  endtask

  virtual task apply_reset_n();
    //lut_ram has no reset, but we will still wait a bit to start testing
    repeat(DEFAULT_RESET_CYCLES) @(vif.cb_drv);
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

class id_stage_base_test extends uvm_test;
  `uvm_component_utils(id_stage_base_test)

  virtual id_stage_intf id_vif;
  id_stage_env          env;
  id_stage_base_seq     seq;

  function new(string name = "id_stage_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = id_stage_env::type_id::create("env", this);

    if(!uvm_config_db#(virtual id_stage_intf)::get(this, "", "id_stage_vif", id_vif))
      `uvm_fatal("TEST", "Could not get id_vif")

    uvm_config_db#(virtual id_stage_intf)::set(this, "env.agn.*", "id_stage_vif", id_vif);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    if(seq == null) begin
      `uvm_fatal("BASE_TEST", "No sequence set")
    end
    else begin
      seq.start(env.agn.seqr);
    end
    repeat(ID_STAGE_LATENCY + 1) @(id_vif.cb_drv);   //wait for testing to finish up

    phase.drop_objection(this);
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

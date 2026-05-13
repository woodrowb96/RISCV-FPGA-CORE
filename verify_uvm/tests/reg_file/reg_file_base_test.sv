class reg_file_base_test extends uvm_test;
  `uvm_component_utils(reg_file_base_test)

  virtual reg_file_intf vif;
  reg_file_env          env;
  reg_file_base_seq     seq;

  function new(string name = "reg_file_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = reg_file_env::type_id::create("env", this);

    if(!uvm_config_db#(virtual reg_file_intf)::get(this, "", "reg_file_vif", vif))
      `uvm_fatal("TEST", "Could not get vif")

    uvm_config_db#(virtual reg_file_intf)::set(this, "env.agn.*", "reg_file_vif", vif);
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
    repeat(REG_FILE_LATENCY + 1) @(vif.cb_drv);   //wait for testing to finish up

    phase.drop_objection(this);
  endtask

  virtual task apply_reset_n();
    //reg_file has no reset, but we will still wait a bit to start testing
    repeat(DEFAULT_RESET_CYCLES) @(vif.cb_drv);
  endtask
endclass

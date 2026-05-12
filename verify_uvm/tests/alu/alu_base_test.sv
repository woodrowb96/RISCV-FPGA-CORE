class alu_base_test extends uvm_test;
  `uvm_component_utils(alu_base_test)

  virtual alu_intf vif;
  alu_env      env;
  alu_base_seq seq;

  function new(string name = "alu_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = alu_env::type_id::create("env", this);

    if(!uvm_config_db#(virtual alu_intf)::get(this, "", "alu_vif", vif))
      `uvm_fatal("TEST", "Could not get vif")

    uvm_config_db#(virtual alu_intf)::set(this, "env.agn.*", "alu_vif", vif);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    apply_reset_n();
    if(seq == null) begin
      `uvm_fatal("RAND_TEST", "No sequence set")
    end
    else begin
      seq.start(env.agn.seqr);
    end
    repeat(ALU_LATENCY + 1) @(vif.cb_drv);   //wait for testing to finish up

    phase.drop_objection(this);
  endtask

  virtual task apply_reset_n();
    //ALU is purely comb with no reset, but we will still wait a bit to start testing
    repeat(DEFAULT_RESET_CYCLES) @(vif.cb_drv);
  endtask
endclass

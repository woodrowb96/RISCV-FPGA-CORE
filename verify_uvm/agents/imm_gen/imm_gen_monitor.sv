class imm_gen_monitor extends uvm_monitor;
  `uvm_component_utils(imm_gen_monitor)

  virtual imm_gen_intf vif;
  uvm_analysis_port #(imm_gen_seq_item) observed_ap;

  function new(string name = "imm_gen_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual imm_gen_intf)::get(this, "", "imm_gen_vif", vif)) begin
      `uvm_fatal("MON", "could not get vif");
    end

    observed_ap = new("observed_ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    imm_gen_seq_item item;
    super.run_phase(phase);

    @(vif.cb_mon); //Dont sample the first cycle, nothings been driven yet

    forever begin
      @(vif.cb_mon);
      item = imm_gen_seq_item::type_id::create("item");

      //sample DUT input
      item.inst = vif.cb_mon.inst;
      //sample DUT output
      item.imm  = vif.cb_mon.imm;

      observed_ap.write(item);
      `uvm_info("MON", $sformatf("Saw item %s", item.convert2string()), UVM_HIGH)
    end
  endtask
endclass

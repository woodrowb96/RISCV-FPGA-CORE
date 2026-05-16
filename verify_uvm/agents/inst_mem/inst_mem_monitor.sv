class inst_mem_monitor extends uvm_monitor;
  `uvm_component_utils(inst_mem_monitor)

  virtual inst_mem_intf vif;
  uvm_analysis_port #(inst_mem_seq_item) observed_ap;

  function new(string name = "inst_mem_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual inst_mem_intf)::get(this, "", "inst_mem_vif", vif)) begin
      `uvm_fatal("MON", "could not get vif");
    end

    observed_ap = new("observed_ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    inst_mem_seq_item item;
    super.run_phase(phase);

    @(vif.cb_mon); //Dont sample the first cycle, nothings been driven yet

    forever begin
      @(vif.cb_mon);
      item = inst_mem_seq_item::type_id::create("item");

      //sample DUT input
      item.inst_addr = vif.cb_mon.inst_addr;
      //sample DUT output
      item.inst      = vif.cb_mon.inst;

      observed_ap.write(item);
      `uvm_info("MON", $sformatf("Saw item %s", item.convert2string()), UVM_HIGH)
    end
  endtask
endclass

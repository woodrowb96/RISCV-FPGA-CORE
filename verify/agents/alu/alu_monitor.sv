class alu_monitor extends uvm_monitor;
  `uvm_component_utils(alu_monitor)

  virtual alu_intf vif;
  uvm_analysis_port #(alu_seq_item) observed_ap;

  function new(string name = "alu_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual alu_intf)::get(this, "", "alu_vif", vif)) begin
      `uvm_fatal("MON", "could not get vif");
    end

    observed_ap = new("observed_ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    alu_seq_item item;
    super.run_phase(phase);

    @(vif.cb_mon); //Dont sample the first cycle, nothings been driven yet

    forever begin
      @(vif.cb_mon);
      item = alu_seq_item::type_id::create("item");

      //sample DUT input
      item.alu_op = vif.cb_mon.alu_op;
      item.in_a   = vif.cb_mon.in_a;
      item.in_b   = vif.cb_mon.in_b;
      //sample DUT output
      item.result = vif.cb_mon.result;
      item.zero   = vif.cb_mon.zero;

      observed_ap.write(item);
      `uvm_info("MON", $sformatf("Saw item %s", item.convert2string()), UVM_HIGH)
    end
  endtask
endclass

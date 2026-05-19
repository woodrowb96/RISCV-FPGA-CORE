class lut_ram_monitor extends uvm_monitor;
  `uvm_component_utils(lut_ram_monitor)

  virtual lut_ram_intf vif;
  uvm_analysis_port #(lut_ram_seq_item) observed_ap;

  function new(string name = "lut_ram_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual lut_ram_intf)::get(this, "", "lut_ram_vif", vif)) begin
      `uvm_fatal("MON", "could not get vif");
    end

    observed_ap = new("observed_ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    lut_ram_seq_item item;
    super.run_phase(phase);

    @(vif.cb_mon); //Dont sample the first cycle, nothings been driven yet

    forever begin
      @(vif.cb_mon);
      item = lut_ram_seq_item::type_id::create("item");

      //sample DUT inputs
      item.wr_en   = vif.cb_mon.wr_en;
      item.wr_addr = vif.cb_mon.wr_addr;
      item.rd_addr = vif.cb_mon.rd_addr;
      item.wr_data = vif.cb_mon.wr_data;
      //sample DUT output
      item.rd_data = vif.cb_mon.rd_data;

      observed_ap.write(item);
      `uvm_info("MON", $sformatf("Saw item %s", item.convert2string()), UVM_HIGH)
    end
  endtask
endclass

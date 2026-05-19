class data_mem_monitor extends uvm_monitor;
  `uvm_component_utils(data_mem_monitor)

  virtual data_mem_intf vif;
  uvm_analysis_port #(data_mem_seq_item) observed_ap;

  function new(string name = "data_mem_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual data_mem_intf)::get(this, "", "data_mem_vif", vif)) begin
      `uvm_fatal("MON", "could not get vif");
    end

    observed_ap = new("observed_ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    data_mem_seq_item item;
    super.run_phase(phase);

    @(vif.cb_mon); //Dont sample the first cycle, nothings been driven yet

    forever begin
      @(vif.cb_mon);
      item = data_mem_seq_item::type_id::create("item");

      //sample DUT inputs
      item.wr_sel  = vif.cb_mon.wr_sel;
      item.addr    = vif.cb_mon.addr;
      item.wr_data = vif.cb_mon.wr_data;
      //sample DUT output
      item.rd_data = vif.cb_mon.rd_data;

      observed_ap.write(item);
      `uvm_info("MON", $sformatf("Saw item %s", item.convert2string()), UVM_HIGH)
    end
  endtask
endclass

class reg_file_monitor extends uvm_monitor;
  `uvm_component_utils(reg_file_monitor)

  virtual reg_file_intf vif;
  uvm_analysis_port #(reg_file_seq_item) observed_ap;

  function new(string name = "reg_file_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual reg_file_intf)::get(this, "", "reg_file_vif", vif)) begin
      `uvm_fatal("MON", "could not get vif");
    end

    observed_ap = new("observed_ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    reg_file_seq_item item;
    super.run_phase(phase);

    @(vif.cb_mon); //Dont sample the first cycle, nothings been driven yet

    forever begin
      @(vif.cb_mon);
      item = reg_file_seq_item::type_id::create("item");
      item.write_en     = vif.cb_mon.write_en;
      item.write_addr    = vif.cb_mon.write_addr;
      item.write_data   = vif.cb_mon.write_data;
      item.read_addr_1  = vif.cb_mon.read_addr_1;
      item.read_addr_2  = vif.cb_mon.read_addr_2;
      item.read_data_1 = vif.cb_mon.read_data_1;
      item.read_data_2 = vif.cb_mon.read_data_2;

      observed_ap.write(item);
      `uvm_info("MON", $sformatf("Saw item %s", item.convert2string()), UVM_HIGH)
    end
  endtask
endclass

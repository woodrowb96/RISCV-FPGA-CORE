class reset_monitor extends uvm_monitor;
  `uvm_component_utils(reset_monitor)

  virtual reset_intf vif;
  uvm_analysis_port #(reset_seq_item) observed_ap;

  function new(string name = "reset_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual reset_intf)::get(this, "", "reset_vif", vif)) begin
      `uvm_fatal("MON", "could not get vif");
    end

    observed_ap = new("observed_ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    reset_seq_item item;
    super.run_phase(phase);

    @(vif.cb_mon); //clk in initial reset value

    forever begin
      item = reset_seq_item::type_id::create("item");
      item.assert_duration = 0;
      item.idle_duration = 0;

      while(vif.cb_mon.reset_n === 1'b0) begin
        item.assert_duration++;
        @(vif.cb_mon);
      end

      while(vif.cb_mon.reset_n === 1'b1) begin
        item.idle_duration++;
        @(vif.cb_mon);
      end

      observed_ap.write(item);
    end
  endtask
endclass

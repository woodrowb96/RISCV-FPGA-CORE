class reset_driver extends uvm_driver #(reset_seq_item);
  `uvm_component_utils(reset_driver)

  virtual reset_intf vif;

  function new(string name = "reset_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual reset_intf)::get(this, "", "reset_vif", vif)) begin
      `uvm_fatal("DRV", "Could not get vif")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    reset_seq_item item;
    super.run_phase(phase);

    vif.reset_n = 1'b0;
    @(vif.cb_drv);

    forever begin
      seq_item_port.get_next_item(item);

      vif.cb_drv.reset_n <= '0;
      repeat(item.assert_duration) @(vif.cb_drv);

      vif.cb_drv.reset_n <= '1;
      repeat(item.idle_duration) @(vif.cb_drv);


      seq_item_port.item_done();
    end
  endtask
endclass

class data_mem_driver extends uvm_driver #(data_mem_seq_item);
  `uvm_component_utils(data_mem_driver)

  virtual data_mem_intf vif;

  function new(string name = "data_mem_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual data_mem_intf)::get(this, "", "data_mem_vif", vif)) begin
      `uvm_fatal("DRV", "Could not get vif")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    data_mem_seq_item item;
    super.run_phase(phase);

    @(vif.cb_drv);
    vif.cb_drv.store_byte_sel  <= 4'b0000;   //no write during the reset period
    vif.cb_drv.addr    <= '0;
    vif.cb_drv.store_data <= '0;

    forever begin
      seq_item_port.get_next_item(item);

      @(vif.cb_drv);
      vif.cb_drv.store_byte_sel  <= item.store_byte_sel;
      vif.cb_drv.addr    <= item.addr;
      vif.cb_drv.store_data <= item.store_data;

      seq_item_port.item_done();
    end
  endtask
endclass

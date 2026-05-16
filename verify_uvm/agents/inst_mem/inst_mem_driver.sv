class inst_mem_driver extends uvm_driver #(inst_mem_seq_item);
  `uvm_component_utils(inst_mem_driver)

  virtual inst_mem_intf vif;

  function new(string name = "inst_mem_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual inst_mem_intf)::get(this, "", "inst_mem_vif", vif)) begin
      `uvm_fatal("DRV", "Could not get vif")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    inst_mem_seq_item item;
    super.run_phase(phase);

    @(vif.cb_drv);
    vif.cb_drv.inst_addr <= '0;

    forever begin
      seq_item_port.get_next_item(item);

      @(vif.cb_drv);
      vif.cb_drv.inst_addr <= item.inst_addr;

      seq_item_port.item_done();
    end
  endtask
endclass

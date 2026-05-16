class lut_ram_driver extends uvm_driver #(lut_ram_seq_item);
  `uvm_component_utils(lut_ram_driver)

  virtual lut_ram_intf vif;

  function new(string name = "lut_ram_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual lut_ram_intf)::get(this, "", "lut_ram_vif", vif)) begin
      `uvm_fatal("DRV", "Could not get vif")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    lut_ram_seq_item item;
    super.run_phase(phase);

    @(vif.cb_drv);
    vif.cb_drv.wr_en   <= 1'b0;
    vif.cb_drv.wr_addr <= '0;
    vif.cb_drv.rd_addr <= '0;
    vif.cb_drv.wr_data <= '0;

    forever begin
      seq_item_port.get_next_item(item);

      @(vif.cb_drv);
      vif.cb_drv.wr_en   <= item.wr_en;
      vif.cb_drv.wr_addr <= item.wr_addr;
      vif.cb_drv.rd_addr <= item.rd_addr;
      vif.cb_drv.wr_data <= item.wr_data;

      seq_item_port.item_done();
    end
  endtask
endclass

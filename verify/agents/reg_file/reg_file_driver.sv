class reg_file_driver extends uvm_driver #(reg_file_seq_item);
  `uvm_component_utils(reg_file_driver)

  virtual reg_file_intf vif;

  function new(string name = "reg_file_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual reg_file_intf)::get(this, "", "reg_file_vif", vif)) begin
      `uvm_fatal("DRV", "Could not get vif")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    reg_file_seq_item item;
    super.run_phase(phase);

    @(vif.cb_drv);
    vif.cb_drv.write_en    <= 1'b0;
    vif.cb_drv.write_addr   <= X0;
    vif.cb_drv.read_addr_1 <= X0;
    vif.cb_drv.read_addr_2 <= X0;
    vif.cb_drv.write_data  <= '0;

    forever begin
      seq_item_port.get_next_item(item);

      @(vif.cb_drv);
      vif.cb_drv.write_en     <= item.write_en;
      vif.cb_drv.write_addr    <= item.write_addr;
      vif.cb_drv.write_data   <= item.write_data;
      vif.cb_drv.read_addr_1  <= item.read_addr_1;
      vif.cb_drv.read_addr_2  <= item.read_addr_2;

      seq_item_port.item_done();
    end
  endtask
endclass

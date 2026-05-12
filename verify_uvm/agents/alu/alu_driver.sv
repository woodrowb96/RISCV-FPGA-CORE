class alu_driver extends uvm_driver #(alu_seq_item);
  `uvm_component_utils(alu_driver)

  virtual alu_intf vif;

  function new(string name = "alu_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual alu_intf)::get(this, "", "alu_vif", vif)) begin
      `uvm_fatal("DRV", "Could not get vif")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    alu_seq_item item;
    super.run_phase(phase);

    forever begin
      seq_item_port.get_next_item(item);

      @(vif.cb_drv);
      vif.cb_drv.alu_op <= item.alu_op;
      vif.cb_drv.in_a   <= item.in_a;
      vif.cb_drv.in_b   <= item.in_b;

      seq_item_port.item_done();
    end
  endtask
endclass

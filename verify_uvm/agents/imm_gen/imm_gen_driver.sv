class imm_gen_driver extends uvm_driver #(imm_gen_seq_item);
  `uvm_component_utils(imm_gen_driver)

  virtual imm_gen_intf vif;

  function new(string name = "imm_gen_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual imm_gen_intf)::get(this, "", "imm_gen_vif", vif)) begin
      `uvm_fatal("DRV", "Could not get vif")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    imm_gen_seq_item item;
    super.run_phase(phase);

    @(vif.cb_drv);
    vif.cb_drv.inst <= {25'b0, OP_REG};  //R-type, imm=0 -- safe valid-opcode initial value

    forever begin
      seq_item_port.get_next_item(item);

      @(vif.cb_drv);
      vif.cb_drv.inst <= item.inst;

      seq_item_port.item_done();
    end
  endtask
endclass

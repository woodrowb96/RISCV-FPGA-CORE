class id_stage_driver extends uvm_driver #(id_stage_seq_item);
  `uvm_component_utils(id_stage_driver)

  virtual id_stage_intf id_vif;

  function new(string name = "id_stage_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual id_stage_intf)::get(this, "", "id_stage_vif", id_vif)) begin
      `uvm_fatal("DRV", "Could not get id_stage vif")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    id_stage_seq_item item;
    super.run_phase(phase);

    //Initialize the interface
    id_vif.rd_wr_en_wb = '0;
    id_vif.pc_if       = '0;
    id_vif.inst_if     = NOP;
    id_vif.rd_data_wb  = 'd1;
    @(id_vif.cb_drv);

    forever begin
      seq_item_port.get_next_item(item);

      @(id_vif.cb_drv);
      id_vif.cb_drv.rd_wr_en_wb <= item.rd_wr_en_wb;
      id_vif.cb_drv.pc_if       <= item.pc_if;
      id_vif.cb_drv.inst_if     <= item.inst_if.to_word();
      id_vif.cb_drv.rd_data_wb  <= item.rd_data_wb;

      seq_item_port.item_done();
    end
  endtask
endclass


class id_stage_monitor extends uvm_monitor;
  `uvm_component_utils(id_stage_monitor)

  virtual id_stage_intf id_vif;
  uvm_analysis_port #(id_stage_seq_item) observed_ap;

  function new(string name = "id_stage_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual id_stage_intf)::get(this, "", "id_stage_vif", id_vif)) begin
      `uvm_fatal("MON", "could not get vif");
    end

    observed_ap = new("observed_ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    id_stage_seq_item item;
    word_t            inst_word;
    super.run_phase(phase);

    forever begin
      @(id_vif.cb_mon);
      item = id_stage_seq_item::type_id::create("item");

      item.rd_wr_en_wb = id_vif.cb_mon.rd_wr_en_wb;
      item.pc_if       = id_vif.cb_mon.pc_if;
      inst_word        = id_vif.cb_mon.inst_if;
      item.rd_data_wb  = id_vif.cb_mon.rd_data_wb;
      item.pc_id       = id_vif.cb_mon.pc_id;
      item.rs1_data_id = id_vif.cb_mon.rs1_data_id;
      item.rs2_data_id = id_vif.cb_mon.rs2_data_id;
      item.imm_id      = id_vif.cb_mon.imm_id;

      item.inst_if.from_word(inst_word);

      observed_ap.write(item);
      `uvm_info("MON", $sformatf("Saw item %s", item.convert2string()), UVM_HIGH)
    end
  endtask
endclass

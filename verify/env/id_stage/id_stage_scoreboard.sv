class id_stage_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(id_stage_scoreboard)

  id_stage_ref_model ref_model;

  uvm_analysis_imp  #(id_stage_seq_item, id_stage_scoreboard) observed_imp; //get observed from monitor
  // uvm_analysis_port #(id_stage_seq_item)                      coverage_ap;  //send passing items to coverage

  function new(string name = "id_stage_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_imp = new("observed_imp", this);
    // coverage_ap  = new("coverage_ap", this);
    ref_model    = id_stage_ref_model::type_id::create("ref_model");
  endfunction

  virtual function void write(id_stage_seq_item actual);
    id_stage_seq_item expected;

    `uvm_info("SCB" , $sformatf("actual:%s", actual.convert2string()), UVM_HIGH)

    expected = id_stage_seq_item::type_id::create("expected");
    expected.rd_wr_en_wb = actual.rd_wr_en_wb;
    expected.inst_if     = actual.inst_if;
    expected.pc_if       = actual.pc_if;
    expected.rd_data_wb  = actual.rd_data_wb;

    //Predict expected output
    ref_model.predict(actual);
    expected.pc_id       = ref_model.ref_pc_id;
    expected.imm_id      = ref_model.ref_imm_id;
    expected.rs1_data_id = ref_model.ref_rs1_data_id;
    expected.rs2_data_id = ref_model.ref_rs2_data_id;

    //If we pass send the item to coverage, else report error
    if(actual.compare(expected)) begin
      // coverage_ap.write(actual);
    end
    else begin
      `uvm_error("SCB", $sformatf("Mismatch!\n  (actual)   %s\n  (expected) %s",
                                  actual.convert2string(), expected.convert2string()))
    end

    ref_model.update(actual);
  endfunction
endclass

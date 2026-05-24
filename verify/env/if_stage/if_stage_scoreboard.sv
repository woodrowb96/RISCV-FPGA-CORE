class if_stage_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(if_stage_scoreboard)

  if_stage_ref_model ref_model;
  string program_file;

  uvm_analysis_imp  #(if_stage_seq_item, if_stage_scoreboard) observed_imp; //get observed from monitor
  uvm_analysis_port #(if_stage_seq_item)                      coverage_ap;  //send passing items to coverage

  function new(string name = "if_stage_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_imp = new("observed_imp", this);
    coverage_ap  = new("coverage_ap", this);
    ref_model    = if_stage_ref_model::type_id::create("ref_model");

    //get the program file from config_db and load it into the ref_model rom
    if(!uvm_config_db#(string)::get(this, "", "if_stage_program", program_file))
      `uvm_fatal("SCB", "Could not get if_stage_program from config_db")

    //load data into ref_inst mem
    ref_model.load_program(program_file);
  endfunction

  virtual function void write(if_stage_seq_item actual);
    if_stage_seq_item expected;

    `uvm_info("SCB" , $sformatf("actual:%s", actual.convert2string()), UVM_HIGH)

    expected = if_stage_seq_item::type_id::create("expected");
    expected.branch_ex        = actual.branch_ex;
    expected.branch_target_ex = actual.branch_target_ex;

    //Predict expected output
    expected.pc_if   = ref_model.ref_pc;
    expected.inst_if = ref_model.fetch_inst();

    //If we pass send the item to coverage, else report error
    if(actual.compare(expected)) begin
      coverage_ap.write(actual);
    end
    else begin
      `uvm_error("SCB", $sformatf("Mismatch!\n  (actual)   %s\n  (expected) %s",
                                  actual.convert2string(), expected.convert2string()))
    end

    ref_model.update(actual);
  endfunction
endclass

class inst_mem_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(inst_mem_scoreboard)

  inst_mem_ref_model ref_model;
  string             program_file;

  uvm_analysis_imp  #(inst_mem_seq_item, inst_mem_scoreboard) observed_imp; //get observed items from mon
  uvm_analysis_port #(inst_mem_seq_item)                      coverage_ap;  //send passing items to coverage

  function new(string name = "inst_mem_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_imp = new("observed_imp", this);
    coverage_ap  = new("coverage_ap", this);

    ref_model = inst_mem_ref_model::type_id::create("ref_model");

    //get the program file from config_db and load it into the ref_model rom
    if(!uvm_config_db#(string)::get(this, "", "inst_mem_program", program_file))
      `uvm_fatal("SCB", "Could not get inst_mem_program from config_db")

    //load data into ref_inst mem
    ref_model.load_program(program_file);
  endfunction

  virtual function void write(inst_mem_seq_item actual);
    inst_mem_seq_item expected;

    `uvm_info("SCB" , $sformatf("actual:%s", actual.convert2string()), UVM_HIGH)

    expected = inst_mem_seq_item::type_id::create("expected");
    expected.inst_addr = actual.inst_addr;
    expected.inst      = ref_model.read(expected.inst_addr);

    //If we pass send the item to coverage, else report error
    if(actual.compare(expected)) begin
      coverage_ap.write(actual);
    end
    else begin
      `uvm_error("SCB", $sformatf("Mismatch!\n  (actual)   %s\n  (expected) %s",
                                  actual.convert2string(), expected.convert2string()))
    end
  endfunction
endclass

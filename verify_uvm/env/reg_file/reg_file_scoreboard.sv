class reg_file_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(reg_file_scoreboard)

  //TODO: add ref_model
  // reg_file_ref_model ref_model;

  uvm_analysis_imp #(reg_file_seq_item, reg_file_scoreboard) observed_imp;

  function new(string name = "reg_file_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_imp = new("observed_imp", this);
    // ref_model = reg_file_ref_model::type_id::create("ref_model");
  endfunction

  virtual function void write(reg_file_seq_item actual);
    reg_file_seq_item expected;

    `uvm_info("SCB" , $sformatf("actual:%s", actual.convert2string()), UVM_HIGH)

    expected = reg_file_seq_item::type_id::create("expected");


    //predict the output

    // if(!actual.compare(expected)) begin
    //   `uvm_fatal("SCB", $sformatf("Error! expected != actual\n
    //                               (expected) %s\n
    //                               (actual)   %s",
    //     actual.convert2string(), expected.convert2string()));
    // end
  endfunction
endclass

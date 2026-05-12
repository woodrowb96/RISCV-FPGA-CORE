class alu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(alu_scoreboard)

  //TODO:put in the ref_model

  uvm_analysis_imp #(alu_seq_item, alu_scoreboard) observed_imp;

  function new(string name = "alu_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_imp = new("observed_imp", this);
    // ref_model = pe_ref_model::type_id::create("ref_model");
  endfunction

  //score our item using the ref model
  virtual function void write(alu_seq_item item);
    `uvm_info("SCB" , $sformatf("%s", item.convert2string()), UVM_HIGH)
    //TODO
  endfunction
endclass

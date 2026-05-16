class imm_gen_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(imm_gen_scoreboard)

  imm_gen_ref_model ref_model;

  uvm_analysis_imp #(imm_gen_seq_item, imm_gen_scoreboard) observed_imp; //get observed items from mon

  function new(string name = "imm_gen_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_imp = new("observed_imp", this);
    ref_model    = imm_gen_ref_model::type_id::create("ref_model");
  endfunction

  //score our item using the ref model
  virtual function void write(imm_gen_seq_item actual);
    imm_gen_seq_item expected;

    `uvm_info("SCB" , $sformatf("actual:%s", actual.convert2string()), UVM_HIGH)

    expected = imm_gen_seq_item::type_id::create("expected");
    expected.inst = actual.inst;

    //predict the output
    expected.imm = ref_model.compute(expected.inst);

    if(!actual.compare(expected)) begin
      `uvm_error("SCB", $sformatf("Mismatch!\n  (actual)   %s\n  (expected) %s",
                                  actual.convert2string(), expected.convert2string()))
    end
  endfunction
endclass

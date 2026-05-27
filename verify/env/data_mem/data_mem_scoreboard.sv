class data_mem_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(data_mem_scoreboard)

  data_mem_ref_model ref_model;

  uvm_analysis_imp  #(data_mem_seq_item, data_mem_scoreboard) observed_imp; //get observed items from mon
  uvm_analysis_port #(data_mem_seq_item)                      coverage_ap;  //send passing items to coverage

  function new(string name = "data_mem_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_imp = new("observed_imp", this);
    coverage_ap  = new("coverage_ap", this);
    ref_model    = data_mem_ref_model::type_id::create("ref_model");
  endfunction

  virtual function void write(data_mem_seq_item actual);
    data_mem_seq_item expected;

    `uvm_info("SCB" , $sformatf("actual:%s", actual.convert2string()), UVM_HIGH)

    expected = data_mem_seq_item::type_id::create("expected");
    expected.store_byte_sel  = actual.store_byte_sel;
    expected.addr    = actual.addr;
    expected.store_data = actual.store_data;

    //reads are combinatorial so we read the ref_model output BEFORE we
    //update the ref_model state
    expected.load_data = ref_model.read(expected.addr);

    //If we pass send the item to coverage, else report error
    if(actual.compare(expected)) begin
      coverage_ap.write(actual);
    end
    else begin
      `uvm_error("SCB", $sformatf("Mismatch!\n  (actual)   %s\n  (expected) %s",
                                  actual.convert2string(), expected.convert2string()))
    end

    //Update the state (write bytes selected by store_byte_sel) AFTER we read
    ref_model.update(expected);
  endfunction
endclass

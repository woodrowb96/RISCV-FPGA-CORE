class reg_file_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(reg_file_scoreboard)

  reg_file_ref_model ref_model;

  uvm_analysis_imp  #(reg_file_seq_item, reg_file_scoreboard) observed_imp; //get observed from monitor
  uvm_analysis_port #(reg_file_seq_item)                      coverage_ap;  //send passing items to coverage

  function new(string name = "reg_file_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_imp = new("observed_imp", this);
    coverage_ap  = new("coverage_ap", this);
    ref_model = reg_file_ref_model::type_id::create("ref_model");
  endfunction

  virtual function void write(reg_file_seq_item actual);
    reg_file_seq_item expected;

    `uvm_info("SCB" , $sformatf("actual:%s", actual.convert2string()), UVM_HIGH)

    expected = reg_file_seq_item::type_id::create("expected");
    expected.write_en    = actual.write_en;
    expected.write_addr   = actual.write_addr;
    expected.write_data  = actual.write_data;
    expected.read_addr_1 = actual.read_addr_1;
    expected.read_addr_2 = actual.read_addr_2;

    //reads are combinatorial so well read the ref_model outputs BEFORE we
    //update the ref_model state
    expected.read_data_1 = ref_model.read(expected.read_addr_1);
    expected.read_data_2 = ref_model.read(expected.read_addr_2);

    //If we pass send the item to coverage, else report error
    if(actual.compare(expected)) begin
      coverage_ap.write(actual);
    end
    else begin
      `uvm_error("SCB", $sformatf("Mismatch!\n  (actual)   %s\n  (expected) %s",
                                  actual.convert2string(), expected.convert2string()))
    end

    //Update the state (write write_data into write_addr) AFTER we read the inputs
    ref_model.update(expected);
  endfunction
endclass

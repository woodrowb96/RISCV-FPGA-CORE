class lut_ram_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(lut_ram_scoreboard)

  lut_ram_ref_model ref_model;

  uvm_analysis_imp #(lut_ram_seq_item, lut_ram_scoreboard) observed_imp; //get observed items from mon

  function new(string name = "lut_ram_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_imp = new("observed_imp", this);
    ref_model    = lut_ram_ref_model::type_id::create("ref_model");
  endfunction

  virtual function void write(lut_ram_seq_item actual);
    lut_ram_seq_item expected;

    `uvm_info("SCB" , $sformatf("actual:%s", actual.convert2string()), UVM_HIGH)

    expected = lut_ram_seq_item::type_id::create("expected");
    expected.wr_en   = actual.wr_en;
    expected.wr_addr = actual.wr_addr;
    expected.wr_data = actual.wr_data;
    expected.rd_addr = actual.rd_addr;

    //reads are combinatorial so well read the ref_model output BEFORE we
    //update the ref_model state
    expected.rd_data = ref_model.read(expected.rd_addr);

    if(!actual.compare(expected)) begin
      `uvm_error("SCB", $sformatf("Mismatch!\n  (actual)   %s\n  (expected) %s",
                                  actual.convert2string(), expected.convert2string()))
    end

    //Update the state (write wr_data into wr_addr) AFTER we read the inputs
    ref_model.update(expected);
  endfunction
endclass

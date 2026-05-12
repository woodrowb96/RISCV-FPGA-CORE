class alu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(alu_scoreboard)

  alu_ref_model ref_model;

  uvm_analysis_imp #(alu_seq_item, alu_scoreboard) observed_imp;

  function new(string name = "alu_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    observed_imp = new("observed_imp", this);
    ref_model = alu_ref_model::type_id::create("ref_model");
  endfunction

  //score our item using the ref model
  virtual function void write(alu_seq_item actual);
    alu_out_t expected;
    `uvm_info("SCB" , $sformatf("actual:%s", actual.convert2string()), UVM_HIGH)

    //predict the output
    expected = ref_model.compute(actual.alu_op, actual.in_a, actual.in_b);

    if(expected.result != actual.result) begin
      `uvm_fatal("SCB", $sformatf("Error! wrong result | expected: %s | actual: result=%0d, zero=%0d",
        actual.convert2string(), expected.result, actual.result));
    end

    if(expected.zero != actual.zero) begin
      `uvm_fatal("SCB", $sformatf("Error! wrong zero: expected: %0d, actual: %0d",
        expected.zero, actual.zero));
    end

  endfunction
endclass

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
    alu_seq_item expected;
    alu_out_t expected_output;

    `uvm_info("SCB" , $sformatf("actual:%s", actual.convert2string()), UVM_HIGH)

    expected = alu_seq_item::type_id::create("expected");
    expected.alu_op = actual.alu_op;
    expected.in_a   = actual.in_a;
    expected.in_b   = actual.in_b;

    //predict the output
    expected_output = ref_model.compute(expected.alu_op, expected.in_a, expected.in_b);
    expected.result = expected_output.result;
    expected.zero   = expected_output.zero;

    if(expected.result != actual.result) begin
      `uvm_fatal("SCB", $sformatf("Error! wrong result\n
                                  (expected) %s\n
                                  (actual)   %s",
        actual.convert2string(), expected.convert2string()));
    end

    if(expected.zero != actual.zero) begin
      // `uvm_fatal("SCB", $sformatf("Error! wrong result\n",
      //                             "(expected) %s\n",
      //                             "(actual)   %s",
      //   actual.convert2string(), expected.convert2string()));
    end

  endfunction
endclass

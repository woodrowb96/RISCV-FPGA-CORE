module tb_alu
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;
  import alu_tests_pkg::*;
();

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  alu_intf intf(.clk);

  /*********** DUT *************/
  alu dut(.alu_op(intf.alu_op),
          .in_a(intf.in_a),
          .in_b(intf.in_b),
          .result(intf.result), 
          .zero(intf.zero) 
          );

  /*********** BIND ASSERTIONS *************/
  // bind tb_alu.dut alu_assert dut_assert(.tb_clk(tb_alu.clk),
  //                                       .alu_op(alu_op),
  //                                       .in_a(in_a),
  //                                       .in_b(in_b),
  //                                       .result(result),
  //                                       .zero(zero)
  //                                       );

  /************ COVERAGE *******************/
  // alu_coverage coverage;

  /**************  TESTING ***************************/
  initial begin
    // coverage = new();
    uvm_config_db#(virtual alu_intf)::set(null, "uvm_test_top", "alu_vif", intf);
    run_test("alu_rand_test");
    $stop(1);
  end
endmodule

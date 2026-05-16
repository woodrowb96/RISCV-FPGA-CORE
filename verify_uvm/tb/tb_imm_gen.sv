module tb_imm_gen
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;
  import imm_gen_tests_pkg::*;
();

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  imm_gen_intf intf(.clk);

  /*********** DUT *************/
  imm_gen dut(.inst(intf.inst),
              .imm(intf.imm)
              );

  /**************  TESTING ***************************/
  initial begin
    uvm_config_db#(virtual imm_gen_intf)::set(null, "uvm_test_top", "imm_gen_vif", intf);
    run_test();
    $stop(1);
  end
endmodule

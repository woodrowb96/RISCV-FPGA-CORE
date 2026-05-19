module tb_if_stage
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;
  import if_stage_tests_pkg::*;
();
  //pick the program the DUT and ref_model both load
  localparam string DUT_PROGRAM = INST_MEM_TEST_1;

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  if_stage_intf if_intf(.clk);
  reset_intf    rst_intf(.clk);

  /*********** DUT *************/
  //DUT is parameterized by program file path; ref_model loads the same
  //file via config_db (set below) so both stay in sync.
  if_stage #(.PROGRAM(DUT_PROGRAM)) dut (
    .clk(clk),
    .reset_n(rst_intf.reset_n),
    .branch(if_intf.branch),
    .branch_target(if_intf.branch_target),
    .pc(if_intf.pc),
    .inst(if_intf.inst)
  );

  /**************  TESTING ***************************/
  initial begin
    uvm_config_db#(virtual if_stage_intf)::set(null, "uvm_test_top", "if_stage_vif", if_intf);
    uvm_config_db#(virtual reset_intf)::set(null, "uvm_test_top", "reset_vif", rst_intf);
    uvm_config_db#(string)::set(null, "uvm_test_top.*", "if_stage_program", DUT_PROGRAM);
    run_test();
    $stop(1);
  end
endmodule

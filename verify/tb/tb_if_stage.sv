import tb_if_stage_tests_pkg::*;
import verify_config_pkg::*;
import tb_if_stage_coverage_pkg::*;
import tb_if_stage_reset_coverage_pkg::*;

module tb_if_stage();
  localparam CLK_PERIOD = 10;
  localparam DEFAULT_TEST_MEM = INST_MEM_TEST_1;

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /********* INTERFACE *********/
  if_stage_intf intf(clk);

  /*********** DUT ***********/
  if_stage #(DEFAULT_TEST_MEM) dut(.clk(clk),
                                   .reset_n(intf.reset_n),
                                   .branch(intf.branch),
                                   .branch_target(intf.branch_target),
                                   .pc(intf.pc),
                                   .inst(intf.inst)
  );

  /******* COVERAGE *************/
  tb_if_stage_coverage        coverage;
  tb_if_stage_reset_coverage  rst_coverage;

  /********** TESTING ********************/
  //See the test and generator packages for full details
  if_stage_main_test           test_main;             //fully random branch_targets
  if_stage_branch_corners_test test_branch_corners;   //branch_targets hit corner addresses
  if_stage_oob_misaligned_test test_oob_misaligned;   //test misaligned and OOB PC/branch_targets

  //We will run testing with no mid-test resets, then again with mid-test resets
  if_stage_base_reset     no_mid_test_rst;
  if_stage_mid_test_reset mid_test_rst;

  if_stage_main_test           test_main_rst;
  if_stage_branch_corners_test test_branch_corners_rst;
  if_stage_oob_misaligned_test test_oob_misaligned_rst;


  initial begin
    coverage     = new();
    rst_coverage = new(intf);

    no_mid_test_rst = new(intf, rst_coverage);
    mid_test_rst    = new(intf, rst_coverage);

    test_main           = new(intf, coverage, no_mid_test_rst, DEFAULT_TEST_MEM);
    test_branch_corners = new(intf, coverage, no_mid_test_rst, DEFAULT_TEST_MEM);
    test_oob_misaligned = new(intf, coverage, no_mid_test_rst, DEFAULT_TEST_MEM);

    test_main_rst           = new(intf, coverage, mid_test_rst, DEFAULT_TEST_MEM);
    test_branch_corners_rst = new(intf, coverage, mid_test_rst, DEFAULT_TEST_MEM);
    test_oob_misaligned_rst = new(intf, coverage, mid_test_rst, DEFAULT_TEST_MEM);

    /********* RUN TESTS ***********/
    //run tests with no mid-test reseting
    test_main.run(1000);
    test_branch_corners.run(500);
    test_oob_misaligned.run(250);

    //Run the test with mid-test reseting
    test_main_rst.run(1000);
    test_branch_corners_rst.run(500);
    test_oob_misaligned_rst.run(250);


    /********* PRINT RESULTS ***********/
    test_main.print_results();
    test_branch_corners.print_results();
    test_oob_misaligned.print_results();
    test_main_rst.print_results();
    test_branch_corners_rst.print_results();
    test_oob_misaligned_rst.print_results();

    $stop(1);
  end
endmodule


module tb_reg_file
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;
  import reg_file_tests_pkg::*;
();
  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  reg_file_intf intf(.clk);

  /*********** DUT *************/
  reg_file dut(.clk(clk),
              .wr_en(intf.wr_en),
              .rd_reg_1(intf.rd_reg_1),
              .rd_reg_2(intf.rd_reg_2),
              .wr_reg(intf.wr_reg),
              .wr_data(intf.wr_data),
              .rd_data_1(intf.rd_data_1),
              .rd_data_2(intf.rd_data_2));

  /*********** BIND ASSERTIONS *************/
  // bind tb_reg_file.dut reg_file_assert dut_assert(.*);

  /************ COVERAGE *******************/
  // tb_reg_file_coverage coverage;

  /**************  TESTING ***************************/

  initial begin
    // coverage = new();
    uvm_config_db#(virtual reg_file_intf)::set(null, "uvm_test_top", "reg_file_vif", intf);
    run_test();
    $stop(1);
  end
endmodule

module tb_data_mem
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;
  import data_mem_tests_pkg::*;
();

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  data_mem_intf intf(.clk);

  /*********** DUT *************/
  data_mem dut(.clk(clk),
               .wr_sel(intf.wr_sel),
               .addr(intf.addr),
               .wr_data(intf.wr_data),
               .rd_data(intf.rd_data)
               );

  /*********** BIND ASSERTIONS *************/
  bind tb_data_mem.dut data_mem_assert dut_assert(.*);

  /**************  TESTING ***************************/
  initial begin
    uvm_config_db#(virtual data_mem_intf)::set(null, "uvm_test_top", "data_mem_vif", intf);
    run_test();
    $stop(1);
  end
endmodule

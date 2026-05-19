module tb_inst_mem
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;
  import inst_mem_tests_pkg::*;
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
  inst_mem_intf intf(.clk);

  /*********** DUT *************/
  //DUT is parameterized by program file path; ref_model loads the same
  //file via config_db (set below) so both stay in sync.
  inst_mem #(.PROGRAM(DUT_PROGRAM)) dut (
    .inst_addr(intf.inst_addr),
    .inst(intf.inst)
  );

  /*********** BIND ASSERTIONS *************/
  bind tb_inst_mem.dut inst_mem_assert dut_assert(.tb_clk(tb_inst_mem.clk),
                                                  .inst_addr(inst_addr),
                                                  .inst(inst)
                                                  );

  /**************  TESTING ***************************/
  initial begin
    uvm_config_db#(virtual inst_mem_intf)::set(null, "uvm_test_top", "inst_mem_vif", intf);
    uvm_config_db#(string)::set(null, "uvm_test_top.*", "inst_mem_program", DUT_PROGRAM);
    run_test();
    $stop(1);
  end
endmodule

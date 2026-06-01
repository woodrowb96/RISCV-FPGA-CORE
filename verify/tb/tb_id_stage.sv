module tb_id_stage
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;
  import id_stage_tests_pkg::*;
();
  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  id_stage_intf id_intf(.clk);

  /*********** DUT *************/
  id_stage dut(
    .clk         (clk),
    .rd_wr_en_wb (id_intf.rd_wr_en_wb),
    .pc_if       (id_intf.pc_if),
    .inst_if     (id_intf.inst_if),
    .rd_data_wb  (id_intf.rd_data_wb),
    .pc_id       (id_intf.pc_id),
    .rs1_data_id (id_intf.rs1_data_id),
    .rs2_data_id (id_intf.rs2_data_id),
    .imm_id      (id_intf.imm_id)
  );

  /**************  TESTING ***************************/
  initial begin
    uvm_config_db#(virtual id_stage_intf)::set(null, "uvm_test_top", "id_stage_vif", id_intf);
    run_test();
    $stop(1);
  end
endmodule

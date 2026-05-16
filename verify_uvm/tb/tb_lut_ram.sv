module tb_lut_ram
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;
  import lut_ram_tests_pkg::*;
();

  /*********** CLK *************/
  bit clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  /*********** INTERFACE *************/
  lut_ram_intf intf(.clk);

  /*********** DUT *************/
  //the DUT is parameterized; the intf and agent use fixed widths from
  //rv32i_verify_pkg, so we just plumb those params through here.
  lut_ram #(.LUT_WIDTH(LUT_RAM_WIDTH), .LUT_DEPTH(LUT_RAM_DEPTH)) dut (
    .clk(clk),
    .wr_en(intf.wr_en),
    .wr_addr(intf.wr_addr),
    .rd_addr(intf.rd_addr),
    .wr_data(intf.wr_data),
    .rd_data(intf.rd_data)
  );

  /**************  TESTING ***************************/
  initial begin
    uvm_config_db#(virtual lut_ram_intf)::set(null, "uvm_test_top", "lut_ram_vif", intf);
    run_test();
    $stop(1);
  end
endmodule

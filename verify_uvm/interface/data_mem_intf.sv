interface data_mem_intf
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
(
  input logic clk
);
  //DUT control
  byte_sel_t wr_sel;
  //DUT input
  word_t addr;
  word_t wr_data;
  //DUT output
  word_t rd_data;

  clocking cb_drv @(posedge clk);
    default output #1;
    output wr_sel, addr, wr_data;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input wr_sel, addr, wr_data, rd_data;
  endclocking
endinterface

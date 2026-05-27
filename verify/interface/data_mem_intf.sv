interface data_mem_intf
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
(
  input logic clk
);
  //DUT control
  byte_sel_t store_byte_sel;
  //DUT input
  word_t addr;
  word_t store_data;
  //DUT output
  word_t load_data;

  clocking cb_drv @(posedge clk);
    default output #1;
    output store_byte_sel, addr, store_data;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input store_byte_sel, addr, store_data, load_data;
  endclocking
endinterface

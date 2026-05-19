interface inst_mem_intf
  import rv32i_defs_pkg::*;
(
  input logic clk
);
  //DUT input
  word_t inst_addr;
  //DUT output
  word_t inst;

  clocking cb_drv @(posedge clk);
    default output #1;
    output inst_addr;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input inst_addr, inst;
  endclocking
endinterface

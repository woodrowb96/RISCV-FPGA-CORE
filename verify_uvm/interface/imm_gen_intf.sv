interface imm_gen_intf
  import rv32i_defs_pkg::*;
(
  input logic clk
);
  //DUT input
  word_t inst;
  //DUT output
  word_t imm;

  clocking cb_drv @(posedge clk);
    default output #1;
    output inst;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input inst, imm;
  endclocking
endinterface

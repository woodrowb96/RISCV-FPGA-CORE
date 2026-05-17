interface if_stage_intf
  import rv32i_defs_pkg::*;
(
  input logic clk
);
  logic  reset_n;
  logic  branch;        //DUT Control
  word_t branch_target; //DUT input
  word_t pc;            //DUT output
  word_t inst;

  clocking cb_drv @(posedge clk);
    default output #1;
    output branch, branch_target, reset_n;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input branch, branch_target, pc, inst, reset_n;
  endclocking
endinterface

interface if_stage_intf
  import rv32i_defs_pkg::*;
(
  input logic clk
);
  logic  branch_taken_ex;        //DUT Control (back-edge from EX)
  word_t branch_target_ex; //DUT input  (back-edge from EX)
  word_t pc_if;            //DUT output
  word_t inst_if;

  clocking cb_drv @(posedge clk);
    default output #1;
    output branch_taken_ex, branch_target_ex;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input branch_taken_ex, branch_target_ex, pc_if, inst_if;
  endclocking
endinterface

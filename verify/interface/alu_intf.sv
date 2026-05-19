interface alu_intf
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
(
  input logic clk
);
  //DUT control
  alu_op_t alu_op;
  //DUT input
  word_t in_a;
  word_t in_b;
  //DUT output
  word_t result;
  logic zero;

  clocking cb_drv @(posedge clk);
    default output #1;
    output alu_op, in_a, in_b;
  endclocking

  //well monitor the DUT input and output
  clocking cb_mon @(posedge clk);
    default input #1step;
    input alu_op, in_a, in_b, result, zero;
  endclocking
endinterface

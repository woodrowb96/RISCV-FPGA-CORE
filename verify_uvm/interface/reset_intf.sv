interface reset_intf
  import rv32i_verify_pkg::*;
(
  input logic clk
);

  logic reset_n;

  clocking cb_drv @(posedge clk);
    default output #1;
    output reset_n;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input reset_n;
  endclocking
endinterface

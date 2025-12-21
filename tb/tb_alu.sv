`timescale 1ns / 1ns

module tb_alu();

  //clock
  logic clk;
  initial clk = 0;
  always #1 clk = ~clk;

  //control
  logic [3:0] alu_op;

  //input
  logic [31:0] in_a;
  logic [31:0] in_b;

  //output
  logic [31:0] result;
  logic zero;

  alu dut(.*);

  task print(string msg = "");
    $display("--------------------------------------");
    $display(msg);
    $display("time: %t", $time);
    $display("--------------------------------------");
    $display("alu_op: %b", alu_op);
    $display("--------------------------------------");
    $display("in_a: %b, in_b: %b", in_a, in_b);
    $display("--------------------------------------");
    $display("result: %b", result);
    $display("zero: %b", zero);
    $display("--------------------------------------");
  endtask

  initial begin
    alu_op = 4'b0000;
    in_a = 32'd0;
    in_b = 32'd0; 
    print();

    #50

    alu_op = 4'b0000;
    in_a = 32'd0;
    in_b = 32'd5;
    print();

    #50

    $stop(1);

  end

endmodule

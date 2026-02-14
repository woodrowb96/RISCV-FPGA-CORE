interface lut_ram_intf #(
    parameter int LUT_WIDTH = 32,
    parameter int LUT_DEPTH = 256
)(input logic clk);

  logic wr_en;
  logic [$clog2(LUT_DEPTH)-1:0] wr_addr;
  logic [$clog2(LUT_DEPTH)-1:0] rd_addr;
  logic [LUT_WIDTH-1:0] wr_data;
  logic [LUT_WIDTH-1:0] rd_data;

  modport monitor(input wr_en, wr_addr, rd_addr, wr_data, rd_data);

  function print(string msg = "");
    $display("-----------------------");
    $display("LUT_RAM_INTERFACE:%s\n",msg);
    $display("time: %t", $time);
    $display("-----------------------");
    $display("wr_en: %b", wr_en);
    $display("-----------------------");
    $display("wr_addr: %d", wr_addr);
    $display("wr_data: %h", wr_data);
    $display("-----------------------");
    $display("rd_addr: %d", rd_addr);
    $display("rd_data: %h", rd_data);
    $display("-----------------------");
  endfunction
endinterface

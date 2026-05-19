interface lut_ram_intf
  import rv32i_verify_pkg::*;
(
  input logic clk
);
  //DUT control
  logic wr_en;
  //DUT input
  lut_ram_addr_t wr_addr;
  lut_ram_addr_t rd_addr;
  lut_ram_data_t wr_data;
  //DUT output
  lut_ram_data_t rd_data;

  clocking cb_drv @(posedge clk);
    default output #1;
    output wr_en, wr_addr, rd_addr, wr_data;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input wr_en, wr_addr, rd_addr, wr_data, rd_data;
  endclocking
endinterface

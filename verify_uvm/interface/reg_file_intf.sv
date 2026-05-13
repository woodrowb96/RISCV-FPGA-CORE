interface reg_file_intf
  import rv32i_defs_pkg::*;
(
  input clk
);
  //DUT control
  logic wr_en = 1'b0;
  //DUT input
  rf_addr_t rd_reg_1 = X0;
  rf_addr_t rd_reg_2 = X0;
  rf_addr_t wr_reg   = X0;
  word_t wr_data     = '0;
  //DUT output
  word_t rd_data_1;
  word_t rd_data_2;

  clocking cb_drv @(posedge clk);
    default output #1;
    output wr_en, rd_reg_1, rd_reg_2, wr_reg, wr_data;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input wr_en, rd_reg_1, rd_reg_2, wr_reg, wr_data, rd_data_1, rd_data_2;
  endclocking
endinterface

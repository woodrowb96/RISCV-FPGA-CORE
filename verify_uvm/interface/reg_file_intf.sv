interface reg_file_intf
  import rv32i_defs_pkg::*;
(
  input clk
);
  //DUT control
  logic wr_en;
  //DUT input
  rf_addr_t rd_reg_1;
  rf_addr_t rd_reg_2;
  rf_addr_t wr_reg;
  word_t wr_data;
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

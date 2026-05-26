interface reg_file_intf
  import rv32i_defs_pkg::*;
(
  input clk
);
  //DUT control
  logic write_en;
  //DUT input
  rf_addr_t read_addr_1;
  rf_addr_t read_addr_2;
  rf_addr_t write_addr;
  word_t write_data;
  //DUT output
  word_t read_data_1;
  word_t read_data_2;

  clocking cb_drv @(posedge clk);
    default output #1;
    output write_en, read_addr_1, read_addr_2, write_addr, write_data;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input write_en, read_addr_1, read_addr_2, write_addr, write_data, read_data_1, read_data_2;
  endclocking
endinterface

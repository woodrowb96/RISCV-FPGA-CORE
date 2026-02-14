package tb_lut_ram_stimulus_pkg;
  import lut_ram_verify_pkg::*;
  import riscv_32i_defs_pkg::*;

  class lut_ram_trans;
    rand logic wr_en;
    rand lut_addr_t wr_addr;
    rand lut_addr_t rd_addr;
    rand word_t wr_data;

    word_t rd_data;

    function print(string msg = "");
      $display("-----------------------");
      $display("LUT_RAM_TRANS:%s\n",msg);
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
  endclass
endpackage

package tb_reg_file_stimulus_pkg;
  import riscv_32i_defs_pkg::*;

  class reg_file_trans;
    rand logic wr_en;
    rand rf_addr_t rd_reg_1;
    rand rf_addr_t rd_reg_2;
    rand rf_addr_t wr_reg;
    rand word_t wr_data;

    word_t rd_data_1;
    word_t rd_data_2;

    //We want to make sure we hit the corners
    //but want to hit non_corners most of the time
    constraint wr_data_corners {
      wr_data dist {
        WORD_ALL_ZEROS                            := 1,
        WORD_ALL_ONES                             := 1,
        [WORD_ALL_ZEROS + 1 : WORD_ALL_ONES - 1]  :/ 10
      };
    }

    function void print(string msg = "");
      $display("[%s] t=%0t wr_en:%0b wr_reg:%0d wr_data:%0h rd_reg_1:%0d rd_reg_2:%0d rd_data_1:%0h rd_data_2:%0h",
               msg, $time, wr_en, wr_reg, wr_data, rd_reg_1, rd_reg_2, rd_data_1, rd_data_2);
    endfunction
  endclass
endpackage




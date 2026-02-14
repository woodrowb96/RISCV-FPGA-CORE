package tb_lut_ram_stimulus_pkg;

  class lut_ram_trans #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256);
    rand logic wr_en;
    rand logic [$clog2(LUT_DEPTH)-1:0] wr_addr;
    rand logic [$clog2(LUT_DEPTH)-1:0] rd_addr;
    rand logic [LUT_WIDTH-1:0] wr_data;

    logic [LUT_WIDTH-1:0] rd_data;

    function bit compare(lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) other);
      return (this.wr_en   === other.wr_en   &&
              this.wr_addr === other.wr_addr &&
              this.rd_addr === other.rd_addr &&
              this.wr_data === other.wr_data &&
              this.rd_data === other.rd_data);
    endfunction

    function void print(string msg = "");
      $display("[%s] t=%0t wr_en:%b wr_addr:%0d rd_addr:%0d wr_data:%h rd_data:%h",
               msg, $time, wr_en, wr_addr, rd_addr, wr_data, rd_data);
    endfunction
  endclass
endpackage

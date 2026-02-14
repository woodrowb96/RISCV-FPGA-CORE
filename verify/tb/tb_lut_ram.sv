import riscv_32i_defs_pkg::*;
import lut_ram_verify_pkg::*;
import tb_lut_ram_stimulus_pkg::*;

module tb_lut_ram();
  localparam CLK_PERIOD = 10;

  //clk
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /************ INTERFACE ***********/
  lut_ram_intf intf(clk);

  /**********  DUT ***************/
  lut_ram dut(.clk(intf.clk),
              .wr_en(intf.wr_en),
              .wr_addr(intf.wr_addr),
              .rd_addr(intf.rd_addr),
              .wr_data(intf.wr_data),
              .rd_data(intf.rd_data)
              );

  /********** TASKS ***********/

  task drive(lut_ram_trans trans);
    intf.wr_en <= trans.wr_en;
    intf.wr_addr <= trans.wr_addr;
    intf.rd_addr <= trans.rd_addr;
    intf.wr_data <= trans.wr_data;
  endtask

  task monitor(lut_ram_trans trans);
    trans.rd_data = intf.rd_data;
  endtask

  /************  TESTING ********/
  lut_ram_trans trans;
  initial begin

    trans = new();

    trans.wr_en = '0;
    trans.wr_addr <= 'd1;
    trans.rd_addr <= 'd1;
    trans.wr_data <= '0;
    drive(trans);

    for(int i = 0; i < 10; i++) begin
      @(posedge intf.clk)
      trans.wr_data <= trans.wr_data + 'd1;
      trans.wr_en <= ~trans.wr_en;
      trans.wr_addr <= i * 10;
      trans.rd_addr <= i * 10;
      drive(trans);
      @(posedge intf.clk)
      #1
      monitor(trans);
      $display("wr_en: %b\n wr_addr: %d, wr_data: %h\nrd_addr: %d, rd_data: %h\n",
                trans.wr_en, trans.wr_addr, trans.wr_data, trans.rd_addr, trans.rd_data);
    end

    $stop(1);
  end

endmodule

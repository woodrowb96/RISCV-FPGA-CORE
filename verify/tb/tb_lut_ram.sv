import riscv_32i_defs_pkg::*;
import tb_lut_ram_stimulus_pkg::*;

module tb_lut_ram();
  localparam CLK_PERIOD = 10;
  localparam MEM_DEPTH = 256;
  localparam MEM_WIDTH = XLEN;
  typedef lut_ram_trans #(MEM_WIDTH, MEM_DEPTH) trans_t;

  //clk
  logic clk;
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  /************ INTERFACE ***********/
  lut_ram_intf #(.LUT_WIDTH(MEM_WIDTH), .LUT_DEPTH(MEM_DEPTH)) intf(clk);

  /**********  DUT ***************/
  lut_ram #(.LUT_WIDTH(MEM_WIDTH), .LUT_DEPTH(MEM_DEPTH)) dut (.clk(intf.clk),
                                                                .wr_en(intf.wr_en),
                                                                .wr_addr(intf.wr_addr),
                                                                .rd_addr(intf.rd_addr),
                                                                .wr_data(intf.wr_data),
                                                                .rd_data(intf.rd_data)
                                                              );

  /*********  LUT REFERENCE MODEL ***************/
  lut_ram_ref_model #(MEM_WIDTH, MEM_DEPTH) ref_lut_ram;

  /********** TASKS ***********/

  task drive(trans_t trans);
    intf.wr_en <= trans.wr_en;
    intf.wr_addr <= trans.wr_addr;
    intf.rd_addr <= trans.rd_addr;
    intf.wr_data <= trans.wr_data;
  endtask

  task monitor(trans_t trans);
    trans.rd_data = intf.rd_data;
  endtask

  int num_tests = 0;
  int num_fails = 0;

  function automatic void score(trans_t trans);
    bit test_fail = 0;

    trans_t expected = ref_lut_ram.process_trans(trans);

    test_fail = trans.compare(expected);

    if(test_fail) begin
      $error("LUT_RAM_TB: test fail");
      trans.print("ACTUAL");
      trans.print("EXPECTED");
      num_fails++;
    end

    num_tests++;
  endfunction

  /************  TESTING ********/
  trans_t trans;
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
      $display("wr_en:%0b wr_addr:%0d wr_data:%0h rd_addr:%0d rd_data:%0h",
                trans.wr_en, trans.wr_addr, trans.wr_data, trans.rd_addr, trans.rd_data);
    end

    $stop(1);
  end

endmodule

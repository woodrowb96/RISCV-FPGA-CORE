import riscv_32i_defs_pkg::*;
import tb_lut_ram_stimulus_pkg::*;
import lut_ram_ref_model_pkg::*;

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

  function automatic void score(trans_t actual);
    trans_t expected = new();

    //expected inputs should match the actual ones
    expected.wr_en = actual.wr_en;
    expected.wr_addr = actual.wr_addr;
    expected.rd_addr = actual.rd_addr;
    expected.wr_data = actual.wr_data;

    //predict the expected output
    expected.rd_data = ref_lut_ram.read(actual.rd_addr);

    //if expected doesnt match actual, then the test has failed
    if(!expected.compare(actual)) begin
      $display("----------------");
      $error("LUT_RAM_TB: test fail");
      expected.print("EXPECTED");
      actual.print("ACTUAL");
      num_fails++;
    end

    num_tests++;
  endfunction

  function void print_test_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %0d", num_tests);
    $display("Total tests failed: %0d", num_fails);
    $display("----------------");
  endfunction

  /************  TESTING ********/
  trans_t trans;
  initial begin

    ref_lut_ram = new();
    trans = new();

    trans.wr_en = '0;
    trans.wr_addr = 'd1;
    trans.rd_addr = 'd1;
    trans.wr_data = '0;
    drive(trans);

    for(int i = 0; i < 10; i++) begin
      @(posedge intf.clk)
      trans.wr_data = trans.wr_data + 'd1;
      trans.wr_en = ~trans.wr_en;
      trans.wr_addr = i * 10;
      trans.rd_addr = i * 10;
      drive(trans);
      @(posedge intf.clk)
      ref_lut_ram.update(trans);
      #1
      monitor(trans);
      score(trans);
    end

    print_test_results();

    $stop(1);
  end

endmodule

`include "../coverage/tb_alu_coverage.sv"
// `timescale 1ns / 1ns

module tb_alu();

  alu_intf intf();

  class general_transaction;
    rand logic [3:0] alu_op;
    rand logic [31:0] in_a;
    rand logic [31:0] in_b;

    constraint valid_ops { alu_op inside {4'b0000, 4'b0001, 4'b0010, 4'b0110}; }

    task print(string msg = "");
    $display("-----------------------");
    $display("TRANSACTION:%s\n",msg);
    $display("time: %t", $time);
    $display("-----------------------");
    $display("alu_op: %b", alu_op);
    $display("-----------------------");
    $display("in_a: %h", in_a);
    $display("in_b: %h", in_b);
    $display("-----------------------");
    endtask
  endclass

  typedef enum {ONLY_CORNERS, ONLY_NON_CORNERS, MIXED} corner_mode;

  virtual class alu_op_specific_transaction extends general_transaction;
    typedef enum {CORNER, NON_CORNER} input_catagory;
    rand input_catagory in_a_cat;
    rand input_catagory in_b_cat;

    corner_mode in_a_mode = MIXED;
    corner_mode in_b_mode = MIXED;

    constraint input_catagories {
      if(in_a_mode == ONLY_CORNERS)
          in_a_cat == CORNER;
      else if(in_a_mode == ONLY_NON_CORNERS)
          in_a_cat == NON_CORNER;
      else if(in_a_mode == MIXED)
        in_a_cat dist {CORNER := 1, NON_CORNER := 100};

      if(in_b_mode == ONLY_CORNERS)
          in_b_cat == CORNER;
      else if(in_b_mode == ONLY_NON_CORNERS)
          in_b_cat == NON_CORNER;
      else if(in_b_mode == MIXED)
        in_b_cat dist {CORNER := 1, NON_CORNER := 100};
    }
  endclass

  class logical_op_transaction extends alu_op_specific_transaction;
    typedef enum {LOW, MED, HIGH} bit_density_level;

    rand bit_density_level density_a;
    rand bit_density_level density_b;

    constraint density_weights {
      density_a dist {LOW := 5, MED := 1, HIGH := 10};
      density_b dist {LOW := 5, MED := 1, HIGH := 10};
    }

    constraint logical_op_inputs {
      if(in_a_cat == CORNER)
        in_a inside {
          32'h0000_0000,
          32'h5555_5555,
          32'haaaa_aaaa,
          32'hffff_ffff
        };
      else {
        !(in_a inside {
          32'h0000_0000,
          32'h5555_5555,
          32'haaaa_aaaa,
          32'hffff_ffff
        });

        // if(density_a == LOW){
        //   foreach(in_a[i])
        //     in_a[i] dist {0 := 10, 1 := 1};
        // } else if (density_a == MED) {
        //   foreach(in_a[i])
        //     in_a[i] dist {0 := 1, 1 := 1};
        // } else {
        //   foreach(in_a[i])
        //     in_a[i] dist {0 := 1, 1 := 10};
        // }
      }

      if(in_b_cat == CORNER)
        in_b inside {
          32'h0000_0000,
          32'h5555_5555,
          32'haaaa_aaaa,
          32'hffff_ffff
          };
      else {
        !(in_b inside {
          32'h0000_0000,
          32'h5555_5555,
          32'haaaa_aaaa,
          32'hffff_ffff
        });

        // if(density_b == LOW){
        //   foreach(in_b[i])
        //     in_b[i] dist {0 := 100, 1 := 1};
        // } else if (density_b == MED) {
        //   foreach(in_b[i])
        //     in_b[i] dist {0 := 1, 1 := 1};
        // } else {
        //   foreach(in_b[i])
        //     in_b[i] dist {0 := 1, 1 := 100};
        // }
      }
    }
  endclass

  class add_op_transaction extends alu_op_specific_transaction;

    constraint add_op { alu_op == 4'b0010; }

    constraint add_op_inputs {
      if(in_a_cat == CORNER)
        in_a inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff
          };
      else {
        in_a inside {[32'h0000_0000 : 32'hffff_ffff]};

        !(in_a inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff
        });
      }

      if(in_b_cat == CORNER)
        in_b inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff
          };
      else {
        in_b inside {[32'h0000_0000 : 32'hffff_ffff]};

        !(in_b inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff
        });
      }
    }
  endclass

  class sub_op_transaction extends alu_op_specific_transaction;

    constraint sub_op { alu_op == 4'b0110; }

    constraint sub_op_inputs {
      if(in_a_cat == CORNER) {
        in_a inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff,
          32'h7fff_ffff,
          32'h8000_0000
          };
          }
      else {
        in_a[31] dist { 1'b0 := 1, 1'b1 := 1 };

        !(in_a inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff,
          32'h7fff_ffff,
          32'h8000_0000
        });
      }

      if(in_b_cat == CORNER) {
        in_b inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff,
          32'h7fff_ffff,
          32'h8000_0000
          };
      }
      else {
        in_b[31] dist { 1'b0 := 1, 1'b1 := 1 };

        !(in_b inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff,
          32'h7fff_ffff,
          32'h8000_0000
        });
      }
    }
  endclass


  task drive(general_transaction trans);
    intf.alu_op = trans.alu_op;
    intf.in_a = trans.in_a;
    intf.in_b = trans.in_b;
  endtask

  typedef struct {
    logic [31:0] result;
    logic zero;
  } expected_output;

  class reference_alu;
    function expected_output expected(logic [3:0] alu_op,
                                      logic [31:0] in_a,
                                      logic [31:0] in_b);
      logic [32:0] in_a_wide = {1'b0, in_a};
      logic [32:0] in_b_wide = {1'b0, in_b};
      logic [32:0] result_wide = '0;
      logic zero = 1'b0;

      expected_output exp;

      if(alu_op == 4'b0110) begin
        result_wide = in_a_wide - in_b_wide;
      end
      else if(alu_op == 4'b0010) begin
        result_wide = in_a_wide + in_b_wide;
      end
      else if(alu_op == 4'b0001) begin
        result_wide = in_a_wide | in_b_wide;
      end
      else if(alu_op == 4'b0000) begin
        result_wide = in_a_wide & in_b_wide;
      end

      if(result_wide[31:0] == '0) begin
        zero = 1'b1;
      end

      exp.result = result_wide[31:0];
      exp.zero = zero;

      return exp;
    endfunction
  endclass

  int num_tests = 0;
  int num_fails = 0;

  reference_alu ref_alu;

  task automatic score_test();

    bit test_fail = 0;
    expected_output expected = ref_alu.expected(intf.alu_op, intf.in_a, intf.in_b);

    if(intf.result != expected.result) begin
      $error("FAIL\nIncorect Result\nExpected: %h",expected.result);
      test_fail = 1;
    end

    if(intf.zero != expected.zero) begin
      $error("Zero flag incorect\nexpected: %b", expected.zero);
      test_fail = 1;
    end

    if(test_fail) begin
      num_fails++;
      intf.print_state();
    end

    num_tests++;
  endtask

  task print_test_results();
    $display("----------------");
    $display("Test results:");
    $display("Total tests ran: %d", num_tests);
    $display("Total tests failed: %d", num_fails);
    $display("----------------");
  endtask

  alu dut(.alu_op(intf.alu_op),
          .in_a(intf.in_a),
          .in_b(intf.in_b),
          .result(intf.result),
          .zero(intf.zero)
          );


  //bind assertions to the dut
  bind tb_alu.dut alu_assert dut_assert(intf.assertion);

  //coverage
  tb_alu_coverage coverage;

  logical_op_transaction alu_log_trans;

  add_op_transaction alu_add_trans;

  sub_op_transaction alu_sub_trans;

  initial begin

    //create coverage and connect it to the interface
    coverage = new(intf.coverage);
    ref_alu = new();
    alu_log_trans = new();
    alu_add_trans = new();
    alu_sub_trans = new();

    /*************  TEST AND ***************/

    for(int i = 0; i < 1000; i++) begin
      alu_log_trans.randomize() with { alu_op == 4'b0000; };
      drive(alu_log_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    // /************   TEST OR *****************/
    for(int i = 0; i < 1000; i++) begin
      alu_log_trans.randomize() with { alu_op == 4'b0001; };
      drive(alu_log_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    // /*****************  TEST ADD **************/
    for(int i = 0; i < 1000; i++) begin
      alu_add_trans.randomize();
      drive(alu_add_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    // /************ TEST SUB ****************/
    for(int i = 0; i < 1000; i++) begin
      if (! alu_sub_trans.randomize() ) begin
        $fatal("sub transaction randomization failed");
      end
      drive(alu_sub_trans);
      #1;
      coverage.sample();
      score_test();
      #49;
    end

    // /************ TEST INVALID OP ****************/
    // 
    // alu_op = 4'b1110;         //not a valid operation
    // in_a = 32'd5;
    // in_b = 32'd2222;
    // #1
    // coverage.sample();
    // score_test(32'd0);     //result should be 0
    // #49
    //
    print_test_results();

    $stop(1);

  end

endmodule

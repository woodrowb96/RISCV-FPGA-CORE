package tb_alu_stimulus_pkg;
  //A general transaction 
  typedef enum {TRUE, FALSE} include_invalid_ops;
  class general_trans;
    rand logic [3:0] alu_op;
    rand logic [31:0] in_a;
    rand logic [31:0] in_b;

    logic [31:0] result;
    logic zero;

    include_invalid_ops inc_inv_ops = FALSE;

    constraint valid_ops {
      (inc_inv_ops == FALSE) -> (alu_op inside {4'b0000, 4'b0001, 4'b0010, 4'b0110});
    }

    function void print(string msg = "");
      $display("-----------------------");
      $display("transaction:%s\n",msg);
      $display("time: %t", $time);
      $display("-----------------------");
      $display("alu_op: %b", alu_op);
      $display("-----------------------");
      $display("in_a: %h", in_a);
      $display("in_b: %h", in_b);
      $display("-----------------------");
      $display("result: %h", result);
      $display("zero: %b", zero);
      $display("-----------------------");
    endfunction
  endclass

  typedef enum {CORNERS_ONLY, //input constrained to corner cases only
                FULL_RANGE,   //input comes from the entire range (corners included)
                WEIGHTED      //input chosen from corner and full_range cats using a dist
                } input_rand_mode;

  virtual class op_specific_trans extends general_trans;
    typedef enum {CORNER, FULL} input_catagory;

    input_catagory in_a_cat;
    input_catagory in_b_cat;

    input_rand_mode in_a_mode = WEIGHTED;
    input_rand_mode in_b_mode = WEIGHTED;

    function input_catagory cat_select(input_rand_mode input_mode);
      input_catagory cat;
      unique case(input_mode)
        CORNERS_ONLY: begin
          return CORNER;
        end
        FULL_RANGE: begin
          return FULL;
        end
        WEIGHTED: begin
          randcase
            2: return CORNER;
            1: return FULL;
          endcase
        end
      endcase
    endfunction

    function void pre_randomize();
      in_a_cat = cat_select(in_a_mode);
      in_b_cat = cat_select(in_b_mode);
    endfunction
  endclass

  class logical_op_trans extends op_specific_trans;
    constraint logical_op_inputs {
      if(in_a_cat == CORNER) {
        in_a inside {
          32'h0000_0000,
          32'h5555_5555,
          32'haaaa_aaaa,
          32'hffff_ffff
        };
      }

      if(in_b_cat == CORNER) {
        in_b inside {
          32'h0000_0000,
          32'h5555_5555,
          32'haaaa_aaaa,
          32'hffff_ffff
        };
      }
    }
  endclass

  class add_op_trans extends op_specific_trans;

    constraint add_op { alu_op == 4'b0010; }

    constraint add_op_inputs {
      if(in_a_cat == CORNER) {
        in_a inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff
        };
      }

      if(in_b_cat == CORNER) {
        in_b inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff
        };
      }
    }
  endclass

  class sub_op_trans extends op_specific_trans;
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

      if(in_b_cat == CORNER) {
        in_b inside {
          32'h0000_0000,
          32'h0000_0001,
          32'hffff_ffff,
          32'h7fff_ffff,
          32'h8000_0000
        };
      }
    }

    function void post_randomize();
      if(in_a_cat == FULL) begin
        randcase
          1: in_a[31:30] = 2'b00;
          1: in_a[31:30] = 2'b01;
          1: in_a[31:30] = 2'b10;
          1: in_a[31:30] = 2'b11;
        endcase
      end

      if(in_b_cat == FULL) begin
        randcase
          1: in_b[31:30] = 2'b00;
          1: in_b[31:30] = 2'b01;
          1: in_b[31:30] = 2'b10;
          1: in_b[31:30] = 2'b11;
        endcase
      end
    endfunction
  endclass
endpackage

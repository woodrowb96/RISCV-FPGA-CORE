package tb_lut_ram_generator_pkg;
  import tb_lut_ram_transaction_pkg::*;

  /******************  NOTE ***********************************/
  //
  //I wanted to do this as inline constraints inside the generator, but vivado
  //xelab fails with a seg fault when I try and do that, so I can only
  //constrain within the transaction class itseld
  //
  /******************************************************/
  class lut_ram_trans_constraints #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256) 
    extends lut_ram_trans #(LUT_WIDTH, LUT_DEPTH);

    localparam longint unsigned ALL_ZEROS = {LUT_WIDTH{1'b0}};
    localparam longint unsigned ALL_ONES = {LUT_WIDTH{1'b1}};
    localparam int     unsigned MIN_ADDR = 0;
    localparam int     unsigned MAX_ADDR = LUT_DEPTH - 1;

    constraint lut_ram_constraints {
      wr_addr dist {
        MIN_ADDR            := 1,
        MAX_ADDR            := 1,
        [MIN_ADDR:MAX_ADDR] :/ 5
      };
      rd_addr dist {
        MIN_ADDR            := 1,
        MAX_ADDR            := 1,
        [MIN_ADDR:MAX_ADDR] :/ 5
      };
      wr_data dist {
        ALL_ZEROS            := 1,
        ALL_ONES             := 1,
        [ALL_ZEROS:ALL_ONES] :/ 5
      };
    }
  endclass

  class tb_lut_ram_generator #(parameter int LUT_WIDTH = 32, parameter int LUT_DEPTH = 256);
    typedef lut_ram_trans #(LUT_WIDTH, LUT_DEPTH) trans_t;
    typedef lut_ram_trans_constraints #(LUT_WIDTH, LUT_DEPTH) trans_constraint_t;
    typedef logic [$clog2(LUT_DEPTH)-1:0] addr_t;
    typedef logic [LUT_WIDTH-1:0] data_t;

    function trans_t gen_trans();
      trans_constraint_t trans = new();
      assert(trans.randomize()) else
        $fatal(1, "TB_LUT_RAM_GENERATOR: gen_trans() randomization failed");
      return trans;
    endfunction
  endclass
endpackage

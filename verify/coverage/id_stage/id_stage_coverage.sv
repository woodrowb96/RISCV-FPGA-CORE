class id_stage_coverage extends uvm_object;
  `uvm_object_utils(id_stage_coverage)

  id_stage_seq_item item;
  bit [RF_DEPTH-1:0] written; //track which registers have been written yet

  function new(string name = "id_stage_coverage");
    super.new(name);
    this.cg = new();
    this.reset_state();
  endfunction

  function void sample(id_stage_seq_item item);
    this.item = item;
    cg.sample();
    update_state();
  endfunction

  function void reset_state();
    written = '0;
  endfunction

  function void update_state();
    if(item.rd_wr_en_wb)
      written[item.inst_if.rd] = 1'b1;
  endfunction

  function void print_coverage_report();
    real total = cg.get_inst_coverage();
    $display("\n========================================");
    $display("***   id_stage_coverage: %6.2f%%        ***", total);
    $display("========================================");
    if (total < 100.0) begin
      $display(" pc_if:                    %6.2f%%", cg.pc_if.get_coverage());
      $display(" opcode:                   %6.2f%%", cg.opcode.get_coverage());
      $display(" imm:                      %6.2f%%", cg.imm.get_coverage());
      $display(" imm_x_op_code:            %6.2f%%", cg.imm_x_op_code.get_coverage());
      $display(" rd_wr_en_wb:              %6.2f%%", cg.rd_wr_en_wb.get_coverage());
      $display(" rd:                       %6.2f%%", cg.rd.get_coverage());
      $display(" rd_x_rd_wr_en_wb:         %6.2f%%", cg.rd_x_rd_wr_en_wb.get_coverage());
      $display(" rd_data_wb:               %6.2f%%", cg.rd_data_wb.get_coverage());
      $display(" rd_x_rd_data_wb:          %6.2f%%", cg.rd_x_rd_data_wb.get_coverage());
      $display(" x0_write_immunity:        %6.2f%%", cg.x0_write_immunity.get_coverage());
      $display(" rs1:                      %6.2f%%", cg.rs1.get_coverage());
      $display(" rs2:                      %6.2f%%", cg.rs2.get_coverage());
      $display(" rs1_x0_read:              %6.2f%%", cg.rs1_x0_read.get_coverage());
      $display(" rs2_x0_read:              %6.2f%%", cg.rs2_x0_read.get_coverage());
      $display("========================================\n");
    end
    else begin
      $display("");
    end
  endfunction

  /*============================ COVERGROUP =================================*/
  covergroup cg;

    /******************** PC coverage *************************/
    //Cover some patterns so we can make sure pc is routed through correctly
    pc_if: coverpoint item.pc_if {
      bins zeros       = {WORD_ALL_ZEROS};
      bins all_ones    = {WORD_ALL_ONES};
      bins alt_ones_55 = {WORD_ALT_ONES_55}; //0101 repeated
      bins alt_ones_aa = {WORD_ALT_ONES_AA}; //1010 repeated
      bins non_corner = default;
    }

    /******************** INST COVERAGE *************************/

    //We want to cover each rv32i instruction type so we can check that its rs/rd/imm fields
    //are parsed correctly
    //we want to cover each opcode
    opcode: coverpoint item.inst[6:0] {
      bins op_reg    = {OP_REG};
      bins op_imm    = {OP_IMM};
      bins op_load   = {OP_LOAD};
      bins op_store  = {OP_STORE};
      bins op_branch = {OP_BRANCH};
      bins op_lui    = {OP_LUI};
      bins op_auipc  = {OP_AUIPC};
      bins op_jal    = {OP_JAL};
      bins op_jalr   = {OP_JALR};
      bins op_fence  = {OP_FENCE};  //Nop
      bins op_system = {OP_SYSTEM}; //implemented as a NOP currently
      illegal_bins invalid = default;
    }

    /************* IMM Coverage ********************/

    imm: coverpoint item.inst_if.imm {
      bins zeros       = {WORD_ALL_ZEROS};
      bins all_ones    = {WORD_ALL_ONES};
      bins alt_ones_55 = {WORD_ALT_ONES_55}; //0101 repeated
      bins alt_ones_aa = {WORD_ALT_ONES_AA}; //1010 repeated
      bins other = default;
    }

    //Make sure the immediate is decoded properly for each op_code
    imm_x_op_code: cross imm, opcode;

    /************* RD coverage ********************/

    rd_wr_en_wb: coverpoint item.rd_wr_en_wb {
      bins write    = {1'b1};
      bins no_write = {1'b0};
    }

    rd: coverpoint item.inst_if.rd {
      ignore_bins x0     = {0}; // we will cover x0 on its own
      bins        non_x0 = {[1:31]};
    }

    //We want to write and NOT write to each bin
    rd_x_rd_wr_en_wb: cross rd, rd_wr_en_wb;

    //We gate with iff(rd_wr_en_wb) because we only care about rd_data when it
    //is actually getting written into the rd register
    rd_data_wb: coverpoint item.rd_data_wb
      iff(item.rd_wr_en_wb) {
        bins zeros       = {WORD_ALL_ZEROS};
        bins all_ones    = {WORD_ALL_ONES};
        bins alt_ones_55 = {WORD_ALT_ONES_55}; //0101 repeated
        bins alt_ones_aa = {WORD_ALT_ONES_AA}; //1010 repeated
        bins non_corner = default;
    }

    rd_x_rd_data_wb: cross rd, rd_data_wb;

    //Note: iff(rd_data_wb) != 0,
    //   - To be able to observe x0 write immunity we need to be attempting to write
    //    a non_zero value into it. X0 should always hold 0, so tyring to
    //    write 0 into it doesnt give us any verifiable info to observe this
    //    coverpoint
    x0_write_immunity: coverpoint (item.inst_if.rd == X0 && item.rd_wr_en_wb == 1'b1)
      iff(item.rd_data_wb != '0) {
        bins hit = {1};
    }

    /**************** RS COVERAGE ******************/

    //Note: iff(written[item.inst_if.rs1])
    //  - we want to make sure we only cover rs when the register has been
    //  written too already. That is the interesting scenario we need to
    //  observe. Observing x's in an unwritten register does not give us much
    //  information to verify.
    rs1: coverpoint item.inst_if.rs1
      iff(written[item.inst_if.rs1]) {
        bins non_x0    = {[1:31]};
    }
    rs2: coverpoint item.inst_if.rs2
      iff(written[item.inst_if.rs2]) {
        bins non_x0 = {[1:31]};
    }

    rs1_x0_read: coverpoint item.inst_if.rs1 {
      bins x0 = {X0};
    }
    rs2_x0_read: coverpoint item.inst_if.rs2 {
      bins x0 = {X0};
    }
  endgroup
endclass

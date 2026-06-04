class if_stage_coverage extends uvm_object;
  `uvm_object_utils(if_stage_coverage);

  if_stage_seq_item item;

  function new(string name = "if_stage_coverage");
    super.new(name);
    this.cg = new();
  endfunction

  function void sample(if_stage_seq_item item);
    this.item = item;
    cg.sample();
  endfunction

  function void print_coverage_report();
    real total = cg.get_inst_coverage();
    $display("\n========================================");
    $display("***   if_stage_coverage: %6.2f%%        ***", total);
    $display("========================================");
    if (total < 100.0) begin
      $display("  branch_taken_ex:                               %6.2f%%", cg.branch_taken_ex.get_coverage());
      $display("  branch_transitions:                      %6.2f%%", cg.branch_transitions.get_coverage());
      $display("  branch_target_ex:                        %6.2f%%", cg.branch_target_ex.get_coverage());
      $display("  branch_distance:                         %6.2f%%", cg.branch_distance.get_coverage());
      $display("  pc_if:                                   %6.2f%%", cg.pc_if.get_coverage());
      $display("  pc_x_branch:                             %6.2f%%", cg.pc_x_branch.get_coverage());
      $display("  inst_if:                                 %6.2f%%", cg.inst_if.get_coverage());
      $display("  misaligned_branch:                       %6.2f%%", cg.misaligned_branch.get_coverage());
      $display("  increment_misaligned_pc:                 %6.2f%%", cg.increment_misaligned_pc.get_coverage());
      $display("  branch_to_oob_pc:                        %6.2f%%", cg.branch_to_oob_pc.get_coverage());
      $display("  increment_to_oob_pc:                     %6.2f%%", cg.increment_to_oob_pc.get_coverage());
      $display("  misaligned_branch_x_branch_to_oob_pc:    %6.2f%%", cg.misaligned_branch_x_branch_to_oob_pc.get_coverage());
      $display("  increment_misaligned_pc_to_oob:          %6.2f%%", cg.increment_misaligned_pc_to_oob.get_coverage());
      $display("========================================\n");
    end
    else begin
      $display("");
    end
  endfunction

  /*==============================  COVERGROUP  =================================*/
  covergroup cg;

    /*************** BRANCH COVERAGE ***************/

    branch_taken_ex: coverpoint item.branch_taken_ex {
      bins taken     = {1};
      bins not_taken = {0};
    }

    //These should get ignored in crosses, but Vivado is crossing them so
    //I'll just split them out
    branch_transitions: coverpoint item.branch_taken_ex {
      bins back_to_back_take          = (1[*2]);
      bins back_to_back_not_take      = (0[*2]);
      bins take_not_taken_taken       = (1 => 0 => 1);
      bins not_taken_take_not_taken   = (0 => 1 => 0);
    }

    //We want to branch to the following corner addresses in memory
    //(we will cover the branch distance from pc in a separate coverpoint)
    branch_target_ex: coverpoint item.branch_target_ex
      iff(item.branch_taken_ex) { //only cover on branch takens
        bins first_addr          = {INST_MEM_FIRST_ADDR};
        bins second_addr         = {INST_MEM_FIRST_ADDR + 'd4};
        bins second_to_last_addr = {INST_MEM_LAST_ADDR  - 'd4};
        bins last_addr           = {INST_MEM_LAST_ADDR};
        bins non_corner          = default;
    }


    /********* BRANCH DISTANCE COVERAGE ***************/

    //We need to collect some coverage for how far from PC we are jumping
    //NOTE:
    //  - According to the RISCV spec the max B-type branches have a max
    //  range of -4096->4094 bytes and J-type branches have a max range of
    //  -1048576->1048574 bytes. My implementation currently is using an inst_mem
    //  that is only 256 words deep. So I will only cover the max range
    //  possible for my implementation (1024 bytes). If in the future the full
    //  range for B-type and J-types are available we will cover those
    //  distances.
    branch_distance: coverpoint $signed(item.branch_target_ex - item.pc_if)
      iff(item.branch_taken_ex) {  //only cover when we are actually branching
        //we want to hit the corner distances
        bins max_neg       = {MAX_NEG_BRANCH_DIST};  //max negative distance physically allowed in mem
        bins pc_minus_four = {-4}; //branch to the instruction below PC
        bins pc            = {0};  //branch to PC
        bins pc_plus_four  = {4};  //branch to the next PC
        bins max_pos       = {MAX_POS_BRANCH_DIST};  //max positive distance physically allowed in mem

        //We want to hit both non_corner negatives and non_corner positives
        bins branch_backward = {[MAX_NEG_BRANCH_DIST + 1 : -8]};
        bins branch_forward  = {[8 : MAX_POS_BRANCH_DIST - 1]};
    }

    /***************** PC COVERAGE ********************/

    //We want PC to hit the following corner addresses
    pc_if: coverpoint item.pc_if {
        bins first_addr          = {INST_MEM_FIRST_ADDR};
        bins second_addr         = {INST_MEM_FIRST_ADDR + 'd4};
        bins second_to_last_addr = {INST_MEM_LAST_ADDR  - 'd4};
        bins last_addr           = {INST_MEM_LAST_ADDR};
        bins non_corner          = default;
    }

    //We want to both branch and not branch from each corner.
    //  -NOTE: if pc is the last_addr and we don't take the branch the
    //         rtl will silently wrap to the start of memory
    pc_x_branch: cross pc_if, branch_taken_ex {
      //Not branching when we are at the last_addr will take us out of
      //bounds. We will ignore it for now and cover OOB PC coverage separately
      ignore_bins last_addr_x_not_taken = binsof(pc_if.last_addr) && binsof(branch_taken_ex.not_taken);
    }


    /**************** INST COVERAGE *******************/

    inst_if: coverpoint item.inst_if {
      bins all_ones   = {WORD_ALL_ONES};
      bins all_zeros  = {WORD_ALL_ZEROS};
      bins non_corner = default;
    }

    /*************** MISALIGNED BRANCH COVERAGE **********************/

    //This shouldn't happen during normal operation, but the rtl silently
    //rounds this down to be word aligned, so we'll cover it. Also in the
    //future when exceptions get implemented this will throw an exception
    misaligned_branch: coverpoint (item.branch_target_ex[1:0] != 2'b00)
      iff(item.branch_taken_ex) { //only cover on actual branches
        bins hit = {1};
    }

    //The only way to get to a misaligned PC is through a misaligned branch
    //(Every PC + 4 after the misaligned branch will also be misaligned).
    //So we are not going to cover hitting misaligned PC addresses by
    //themselves.
    //
    //What is worth covering is incrementing (so not taking a branch) from
    //a misaligned PC (So PC_misaligned + 4). This stresses the PC + 4 logic
    //and makes sure it handles the silent rounding down the misaligned byte_offset properly.
    increment_misaligned_pc: coverpoint (
      (item.pc_if[1:0] != 2'b00) &&  //make sure the current PC is misaligned
      (!item.branch_taken_ex)              //make sure we aren't branching (so doing PC + 4 instead)
    ){
      bins hit = {1};
    }


    /********** OUT OF BOUNDS ACCESS COVERAGE ************/
    //out of bound access will eventually throw an ACCESS FAULT exception,
    //but for now the rtl silently wraps the addresses to the start of
    //memory.

    //PC can either increment (pc + 4) into the out of bounds, or it can
    //branch into out of bounds. We need to cover both scenarios.
    branch_to_oob_pc: coverpoint (item.branch_target_ex > INST_MEM_LAST_ADDR)
      iff(item.branch_taken_ex) {
        bins hit = {1};
    }
    increment_to_oob_pc: coverpoint (
      (item.pc_if == INST_MEM_LAST_ADDR) &&  //if we are at the last address
      (!item.branch_taken_ex)                      //and we don't branch then we will increment OOB
    ) {
        bins hit = {1};
    }

    //We want to branch oob with a misaligned branch_target.
    //(This will stress both wrapping of addresses and rounding down of
    //misaligned byte_offset logic at the same time)
    misaligned_branch_x_branch_to_oob_pc: cross misaligned_branch, branch_to_oob_pc;

    //We want to increment a misaligned PC OOB
    //(This makes sure the PC + 4 logic handles both the wrapping of
    //addresses and the dropping of misaligned byte_offsets at the same time)
    increment_misaligned_pc_to_oob: coverpoint (
      (item.pc_if[1:0] != 2'b00)                           &&  //if the current PC is misaligned
      ({item.pc_if[XLEN-1:2],2'b00} == INST_MEM_LAST_ADDR) &&  //and it points to the last addr (ignoring the byte_offset)
      (!item.branch_taken_ex)                                        //and we don't branch, then we will be incrementing a misaligned PC OOB
    ) {
      bins hit = {1};
    }
  endgroup
endclass

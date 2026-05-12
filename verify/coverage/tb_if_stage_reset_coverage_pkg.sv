/*
    Dedicated coverage for the if_stage reset functionality.

    COVERAGE SAMPLING ASSUMPTIONS:
      - if_stage uses a synchronous reset.
      - sample() should be called in such a way that it is capturing this synchronous
        behavior.
*/
package tb_if_stage_reset_coverage_pkg;
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;

  class tb_if_stage_reset_coverage;
    virtual if_stage_intf vif;

    function new(virtual if_stage_intf vif);
      this.vif = vif;
      this.cg = new();
    endfunction

    function void sample();
      cg.sample();
    endfunction

    /*==============================  COVERGROUP  =================================*/
    covergroup cg;

      /************** RESET COVERAGE ***************/

      reset: coverpoint vif.cb_mon.reset_n {
        bins asserted   = {0};
        bins deasserted = {1};

        bins back_to_back_asserted = (0[*2]); //PC will auto increment if the reset is not asserted
                                              //we want to hold down reset longer than 1 clk cycle at
                                              //least once to make sure the PC doesnt increment
      }


      /********** BRANCH AND PC COVERAGE ***********/

      //NOTE:
      //  - I exclude a branch_target to PC_RESET just to make sure we only
      //    cover this behavior when its useful (in the context of reseting).
      //    A reset is basically a branch to PC_RESET anyways, so the behavior
      //    on a taken branch to PC_RESET is the same regardless of whether
      //    reset is asserted or not. That scenario is not very verifiable
      //    (like we cant verify much useful stuff about reset behavior) and
      //    isnt worth polutig coverage. The much more usefull and
      //    interesting functionality are branches to non-PC_RESET locations
      branch: coverpoint vif.cb_mon.branch
        iff(vif.cb_mon.branch_target != PC_RESET) {
          bins taken     = {1};
          bins not_taken = {0};
      }

      pc: coverpoint vif.cb_mon.pc {
        bins first_addr          = {INST_MEM_FIRST_ADDR};
        bins second_addr         = {INST_MEM_FIRST_ADDR + 'd4};
        bins second_to_last_addr = {INST_MEM_LAST_ADDR  - 'd4};
        bins last_addr           = {INST_MEM_LAST_ADDR};
        bins non_corner          = default;
      }

      //We want to have reset asserted and deaserted at all combos of pc and branch corners
      pc_x_branch_x_reset: cross pc, branch, reset;


      /*********** MISALIGNED AND OOB COVERAGE ******************/

      misaligned_pc: coverpoint (vif.cb_mon.pc[1:0] != 2'b00) {
          bins hit = {1};
      }

      //Did we reset (and not reset) PC when it was misaligned.
      misaligned_pc_x_reset: cross misaligned_pc, reset;

      oob_pc: coverpoint (vif.cb_mon.pc > INST_MEM_LAST_ADDR) {
        bins hit = {1};
      }

      //Did we reset (and not reset) PC when it was out of bounds
      oob_pc_x_reset: cross oob_pc, reset;

      //Did we reset a PC when it was BOTH OOB and misaligned
      misaligned_pc_x_oob_pc_x_reset: cross misaligned_pc, oob_pc, reset;
    endgroup
  endclass

endpackage

/*
  COVERAGE SAMPLING ASSUMPTIONS:
        - sample() is being called AFTER inst_addr has been driven and the
          combinatorial inst output has settled.
*/
class inst_mem_coverage extends uvm_object;
  `uvm_object_utils(inst_mem_coverage);

  inst_mem_seq_item item;

  function new(string name = "inst_mem_coverage");
    super.new(name);
    this.cg = new();
  endfunction

  function void sample(inst_mem_seq_item item);
    this.item = item;
    cg.sample();
  endfunction

  function bit misaligned_addr(word_t inst_addr);
    return inst_addr[1:0] != 2'b00 ? 1 : 0;
  endfunction

  function bit out_of_bound_addr(word_t inst_addr);
    return ((inst_addr >> 2) >= INST_MEM_DEPTH) ? 1 : 0;
  endfunction

  function void print_coverage_report();
    real total = cg.get_inst_coverage();
    $display("\n========================================");
    $display("***   inst_mem_coverage: %6.2f%%        ***", total);
    $display("========================================");
    if (total < 100.0) begin
      $display("  inst_addr:                %6.2f%%", cg.inst_addr.get_coverage());
      $display("  misaligned_access:        %6.2f%%", cg.misaligned_access.get_coverage());
      $display("  out_of_bound_access:      %6.2f%%", cg.out_of_bound_access.get_coverage());
      $display("  inst:                     %6.2f%%", cg.inst.get_coverage());
      $display("========================================\n");
    end
    else begin
      $display("");
    end
  endfunction

  /*==============================  COVERGROUP  =================================*/
  covergroup cg;

    /************* INST_ADDR COVERAGE *****************/
    inst_addr: coverpoint item.inst_addr {
      bins first_addr          = {INST_MEM_FIRST_ADDR};
      bins second_addr         = {INST_MEM_FIRST_ADDR + 'd4};
      bins second_to_last_addr = {INST_MEM_LAST_ADDR  - 'd4};
      bins last_addr           = {INST_MEM_LAST_ADDR};
      bins non_corner          = default;
    }

    //my implementation assumes aligned access, but the module is supposed
    //to handle misaligned silently so we cover it.
    misaligned_access: coverpoint misaligned_addr(item.inst_addr) {
      bins aligned    = {0};
      bins misaligned = {1};
    }

    //my implementation assumes in-bound access, but the module is supposed
    //to handle out-of-bound silently so we cover it.
    out_of_bound_access: coverpoint out_of_bound_addr(item.inst_addr) {
      bins in_bound     = {0};
      bins out_of_bound = {1};
    }

    /************* INST COVERAGE *****************/
    inst: coverpoint item.inst {
      bins all_zeros  = {WORD_ALL_ZEROS};
      bins all_ones   = {WORD_ALL_ONES};
      bins non_corner = default;
    }
  endgroup
endclass

class if_stage_branch_corners_seq extends if_stage_base_seq;
  `uvm_object_utils(if_stage_branch_corners_seq)

  //Used to keep PC in-bounds by forcing a branch when PC is at the last addr in memory.
  word_t prev_pc;

  function new(string name = "if_stage_branch_corners_seq");
    super.new(name);
  endfunction

  virtual task body();
    if_stage_seq_item item;

    prev_pc = PC_RESET;

    for(int i = 0; i < seq_length; i++) begin
      item = if_stage_seq_item::type_id::create("item");

      start_item(item);
      if (!item.randomize() with {
        //force a branch when PC is at the last addr (keep PC in-bounds)
        (prev_pc == INST_MEM_LAST_ADDR) -> (branch_ex == 1);

        branch_ex dist { 1 := 1, 0 := 5 };

        //restrict branch_target to corner addresses
        branch_target_ex inside {
          INST_MEM_FIRST_ADDR,
          INST_MEM_FIRST_ADDR + 4,
          INST_MEM_LAST_ADDR  - 4,
          INST_MEM_LAST_ADDR
        };
      }) `uvm_fatal("SEQ", "Failed item.randomize() (branch_corners)")

      `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
      finish_item(item);

      //update prev_pc: branch taken -> jump to branch_target; else PC += 4
      if (item.branch_ex === 1'b1) begin
        prev_pc = item.branch_target_ex;
      end
      else begin
        prev_pc += 'd4;
      end
    end

    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

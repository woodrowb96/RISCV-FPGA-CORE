/*
  Misaligned and OOB branch_target/PC stimulus.

  These two cases are combined into a single sequence (mirroring the legacy
  if_stage_oob_misaligned_gen) because they share the same PC-concentration
  logic: we want PC to stay near the corner addresses (so misaligned+OOB
  events are frequent), so we force a branch whenever PC walks too far into
  the middle of the program or too far past the last address.

  Two seq_item constraints get disabled:
    - word_aligned_branch_target: lets us hit non-word-aligned targets
    - legal_branch_target_range:  lets us hit targets past INST_MEM_LAST_ADDR

  Both are replaced inline with a dist that concentrates branch_target around
  the first few words and the last few + slightly-OOB words.
*/
class if_stage_misaligned_oob_seq extends if_stage_base_seq;
  `uvm_object_utils(if_stage_misaligned_oob_seq)

  //Used to keep PC concentrated near the corners.
  word_t prev_pc;

  function new(string name = "if_stage_misaligned_oob_seq");
    super.new(name);
  endfunction

  virtual task body();
    if_stage_seq_item item;

    prev_pc = PC_RESET;

    for(int i = 0; i < seq_length; i++) begin
      item = if_stage_seq_item::type_id::create("item");

      start_item(item);

      //disable the seq_item's alignment and in-range constraints so we can
      //drive misaligned + OOB branch_targets
      item.word_aligned_branch_target.constraint_mode(0);
      item.legal_branch_target_range.constraint_mode(0);

      if (!item.randomize() with {
        //force a branch when PC drifts into the middle of the program
        //(keeps stimulus concentrated around the corners)
        ((prev_pc >= (INST_MEM_FIRST_ADDR + 5)) && (prev_pc <= (INST_MEM_LAST_ADDR - 5))) -> (branch == 1);
        //force a branch if PC has walked too far past the last addr
        (prev_pc >= INST_MEM_LAST_ADDR + 5) -> (branch == 1);

        //branch ~9% of the time -- gives PC headroom to walk OOB before
        //being reigned in by a branch
        branch dist { 1 := 1, 0 := 10 };

        //branch_target lives either in the low range or the upper
        //(slightly-OOB) range
        branch_target dist {
          [INST_MEM_FIRST_ADDR     : INST_MEM_FIRST_ADDR + 5] :/ 1,
          [INST_MEM_LAST_ADDR - 5  : INST_MEM_LAST_ADDR + 5]  :/ 1
        };
      }) `uvm_fatal("SEQ", "Failed item.randomize() (misaligned_oob)")

      `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
      finish_item(item);

      //update prev_pc: branch taken -> jump to branch_target; else PC += 4.
      //The DUT stores the raw branch_target/PC+4 in its PC register (including
      //misaligned LSBs and OOB values), so this prediction matches.
      if (item.branch === 1'b1) begin
        prev_pc = item.branch_target;
      end
      else begin
        prev_pc += 'd4;
      end
    end

    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

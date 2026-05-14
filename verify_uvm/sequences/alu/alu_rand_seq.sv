class alu_rand_seq extends alu_base_seq;
  `uvm_object_utils(alu_rand_seq);

  function new(string name = "alu_rand_seq");
    super.new(name);
  endfunction

  virtual task body();
    alu_seq_item item;

    for(int i = 0; i < seq_length; i++) begin
      item = alu_seq_item::type_id::create("item");

      start_item(item);
      randcase
        //logical operations: AND, OR
        1: begin
          if (!item.randomize() with {
            alu_op inside {ALU_AND, ALU_OR};
            in_a dist {
              WORD_ALL_ZEROS                   := 3,
              WORD_ALT_ONES_55                 := 3,
              WORD_ALT_ONES_AA                 := 3,
              WORD_ALL_ONES                    := 3,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 2
            };
            in_b dist {
              WORD_ALL_ZEROS                   := 3,
              WORD_ALT_ONES_55                 := 3,
              WORD_ALT_ONES_AA                 := 3,
              WORD_ALL_ONES                    := 3,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 2
            };
          }) `uvm_fatal("SEQ", "Failed item.randomize() (logical)")
        end

        //add operation
        3: begin
          if (!item.randomize() with {
            alu_op == ALU_ADD;
            in_a dist {
              WORD_UNSIGNED_ZERO               := 3,
              WORD_UNSIGNED_ONE                := 3,
              WORD_MAX_UNSIGNED                := 3,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 2
            };
            in_b dist {
              WORD_UNSIGNED_ZERO               := 3,
              WORD_UNSIGNED_ONE                := 3,
              WORD_MAX_UNSIGNED                := 3,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 2
            };
          }) `uvm_fatal("SEQ", "Failed item.randomize() (add)")
        end

        //sub operation
        3: begin
          if (!item.randomize() with {
            alu_op == ALU_SUB;
            in_a dist {
              WORD_SIGNED_ZERO                 := 4,
              WORD_SIGNED_POS_ONE              := 4,
              WORD_SIGNED_NEG_ONE              := 4,
              WORD_MAX_SIGNED_POS              := 4,
              WORD_MIN_SIGNED_NEG              := 4,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 4
            };
            in_b dist {
              WORD_SIGNED_ZERO                 := 4,
              WORD_SIGNED_POS_ONE              := 4,
              WORD_SIGNED_NEG_ONE              := 4,
              WORD_MAX_SIGNED_POS              := 4,
              WORD_MIN_SIGNED_NEG              := 4,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 4
            };
          }) `uvm_fatal("SEQ", "Failed item.randomize() (sub)")
        end
      endcase

      `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
      finish_item(item);
    end

    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

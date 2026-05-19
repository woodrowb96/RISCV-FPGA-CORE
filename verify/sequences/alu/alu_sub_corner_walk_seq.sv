class alu_sub_corner_walk_seq extends alu_base_seq;
  `uvm_object_utils(alu_sub_corner_walk_seq)

  word_t corners[] = '{
    WORD_SIGNED_ZERO,
    WORD_SIGNED_POS_ONE,
    WORD_SIGNED_NEG_ONE,
    WORD_MAX_SIGNED_POS,
    WORD_MIN_SIGNED_NEG,
    $urandom_range(WORD_SIGNED_POS_ONE   + 1, SIGNED_POS_LOWER_HALF),
    $urandom_range(SIGNED_POS_LOWER_HALF + 1, WORD_MAX_SIGNED_POS   - 1),
    $urandom_range(SIGNED_NEG_LOWER_HALF,     WORD_SIGNED_NEG_ONE   - 1),
    $urandom_range(WORD_MIN_SIGNED_NEG   + 1, SIGNED_NEG_LOWER_HALF - 1)
  };

  int num_items = 0;

  function new(string name = "alu_sub_corner_walk_seq");
    super.new(name);
  endfunction

  virtual task body();
    alu_seq_item item;

    for(int i = 0; i < corners.size(); i++) begin
      for(int j = 0; j < corners.size(); j++) begin
        item = alu_seq_item::type_id::create("item");
        start_item(item);
        item.alu_op = ALU_SUB;
        item.in_a = corners[i];
        item.in_b = corners[j];
        `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
        num_items++;
        finish_item(item);
      end
    end
    `uvm_info("SEQ", $sformatf("Done generating %0d items", num_items), UVM_HIGH);
  endtask
endclass

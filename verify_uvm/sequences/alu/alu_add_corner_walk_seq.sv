class alu_add_corner_walk_seq extends alu_base_seq;
  `uvm_object_utils(alu_add_corner_walk_seq)

  word_t corners[] = '{
    WORD_UNSIGNED_ZERO,
    WORD_UNSIGNED_ONE,
    WORD_MAX_UNSIGNED,
    unsigned_urandom_range(WORD_UNSIGNED_ZERO + 1,       UNSIGNED_LOWER_THIRD),
    unsigned_urandom_range(UNSIGNED_LOWER_THIRD + 1,   UNSIGNED_LOWER_TWO_THIRD),
    unsigned_urandom_range(UNSIGNED_LOWER_TWO_THIRD + 1, WORD_MAX_UNSIGNED - 1)
  };

  int num_items = 0;

  function new(string name = "alu_add_corner_walk_seq");
    super.new(name);
  endfunction

  virtual task body();
    alu_seq_item item;

    for(int i = 0; i < corners.size(); i++) begin
      for(int j = 0; j < corners.size(); j++) begin
        item = alu_seq_item::type_id::create("item");
        start_item(item);
        item.alu_op = ALU_ADD;
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

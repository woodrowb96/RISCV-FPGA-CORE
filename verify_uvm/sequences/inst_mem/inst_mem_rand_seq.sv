class inst_mem_rand_seq extends inst_mem_base_seq;
  `uvm_object_utils(inst_mem_rand_seq);

  function new(string name = "inst_mem_rand_seq");
    super.new(name);
  endfunction

  virtual task body();
    inst_mem_seq_item item;

    for(int i = 0; i < seq_length; i++) begin
      item = inst_mem_seq_item::type_id::create("item");

      start_item(item);
      randcase
        //corner addrs
        1: begin
          if (!item.randomize() with {
            inst_addr inside {
              INST_MEM_FIRST_ADDR,
              INST_MEM_FIRST_ADDR + 4,
              INST_MEM_LAST_ADDR  - 4,
              INST_MEM_LAST_ADDR
            };
          }) `uvm_fatal("SEQ", "Failed item.randomize() (corner_addr)")
        end

        //full range (seq_item's legal_addr_range + word_aligned still active)
        5: begin
          if (!item.randomize())
            `uvm_fatal("SEQ", "Failed item.randomize() (full_range)")
        end
      endcase

      `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
      finish_item(item);
    end

    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

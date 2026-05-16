class inst_mem_oob_seq extends inst_mem_base_seq;
  `uvm_object_utils(inst_mem_oob_seq);

  function new(string name = "inst_mem_oob_seq");
    super.new(name);
  endfunction

  virtual task body();
    inst_mem_seq_item item;

    for(int i = 0; i < seq_length; i++) begin
      item = inst_mem_seq_item::type_id::create("item");

      start_item(item);

      item.legal_addr_range.constraint_mode(0);

      if (!item.randomize() with {
        inst_addr > INST_MEM_LAST_ADDR;
      }) `uvm_fatal("SEQ", "Failed item.randomize() (oob)")

      `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
      finish_item(item);
    end

    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

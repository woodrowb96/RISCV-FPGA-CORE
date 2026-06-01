class id_stage_rand_seq extends id_stage_base_seq;
  `uvm_object_utils(id_stage_rand_seq)

  function new(string name = "id_stage_rand_seq");
    super.new(name);
  endfunction

  virtual task body();
    id_stage_seq_item item;

    for(int i = 0; i < seq_length; i++) begin
      item = id_stage_seq_item::type_id::create("item");

      start_item(item);

      if(!item.randomize())
        `uvm_fatal("SEQ", "Failed item.randomize()")

      `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
      finish_item(item);
    end

    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

class if_stage_rand_seq extends if_stage_base_seq;
  `uvm_object_utils(if_stage_rand_seq)

  function new(string name = "if_stage_rand_seq");
    super.new(name);
  endfunction

  virtual task body();
    if_stage_seq_item item;

    for(int i = 0; i < seq_length; i++) begin
      item = if_stage_seq_item::type_id::create("item");

      start_item(item);
      if(!item.randomize()) begin
        `uvm_fatal("SEQ", "Failed item.randomize()")
      end
      finish_item(item);
    end
    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

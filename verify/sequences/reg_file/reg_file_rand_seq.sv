class reg_file_rand_seq extends reg_file_base_seq;
  `uvm_object_utils(reg_file_rand_seq);

  function new(string name = "reg_file_rand_seq");
    super.new(name);
  endfunction

  virtual task body();
    reg_file_seq_item item;

    for(int i = 0; i < seq_length; i++) begin
      item = reg_file_seq_item::type_id::create("item");

      start_item(item);
      randcase
        //bias toward corner wr_data values
        5: begin
          if (!item.randomize() with {
            wr_data inside { WORD_ALL_ZEROS, WORD_ALL_ONES };
          }) `uvm_fatal("SEQ", "Failed item.randomize() (corners)")
        end

        //fully random wr_data
        1: begin
          if (!item.randomize())
            `uvm_fatal("SEQ", "Failed item.randomize() (full range)")
        end
      endcase

      `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
      finish_item(item);
    end

    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

class data_mem_rand_seq extends data_mem_base_seq;
  `uvm_object_utils(data_mem_rand_seq);

  //Track addresses weve written any bytes to so reads/writes can bias toward
  //addrs that hold real data. Init with 0 so the constraint solver never
  //sees an empty inside set.
  word_t prev_written_addr [$] = {0};

  function new(string name = "data_mem_rand_seq");
    super.new(name);
  endfunction

  virtual task body();
    data_mem_seq_item item;

    for(int i = 0; i < seq_length; i++) begin
      item = data_mem_seq_item::type_id::create("item");

      start_item(item);
      randcase
        //corner addresses
        4: begin
          if (!item.randomize() with {
            addr inside {
              //first word
              DATA_MEM_FIRST_ADDR,
              DATA_MEM_FIRST_ADDR + 1,
              DATA_MEM_FIRST_ADDR + 2,
              DATA_MEM_FIRST_ADDR + 3,
              //last word
              DATA_MEM_LAST_WORD_ADDR,
              DATA_MEM_LAST_WORD_ADDR + 1,
              DATA_MEM_LAST_WORD_ADDR + 2,
              DATA_MEM_LAST_ADDR
            };
            wr_sel dist {
              4'b0000 := 1, //no_write
              4'b0001 := 3, //sb
              4'b0011 := 3, //sh
              4'b1111 := 3  //sw
            };
            wr_data dist {
              WORD_ALL_ZEROS                   := 1,
              WORD_ALL_ONES                    := 1,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 5
            };
          }) `uvm_fatal("SEQ", "Failed item.randomize() (corner_addr)")
        end

        //previously written addresses
        5: begin
          if (!item.randomize() with {
            addr inside { prev_written_addr };
            wr_sel dist {
              4'b0000 := 1,
              4'b0001 := 3,
              4'b0011 := 3,
              4'b1111 := 3
            };
            wr_data dist {
              WORD_ALL_ZEROS                   := 1,
              WORD_ALL_ONES                    := 1,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 5
            };
          }) `uvm_fatal("SEQ", "Failed item.randomize() (prev_written)")
        end

        //full address range
        3: begin
          if (!item.randomize() with {
            wr_sel dist {
              4'b0000 := 1,
              4'b0001 := 3,
              4'b0011 := 3,
              4'b1111 := 3
            };
            wr_data dist {
              WORD_ALL_ZEROS                   := 1,
              WORD_ALL_ONES                    := 1,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 5
            };
          }) `uvm_fatal("SEQ", "Failed item.randomize() (full_range)")
        end
      endcase

      //track addresses where any byte was written
      if (item.wr_sel) prev_written_addr.push_back(item.addr);

      `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
      finish_item(item);
    end

    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

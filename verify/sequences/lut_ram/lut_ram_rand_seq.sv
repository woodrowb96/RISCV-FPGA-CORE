class lut_ram_rand_seq extends lut_ram_base_seq;
  `uvm_object_utils(lut_ram_rand_seq);

  //Track addresses weve written to so reads/writes can bias toward addrs
  //that hold real data. Init with 0 so the constraint solver never sees
  //an empty inside set.
  lut_ram_addr_t prev_written_addr [$] = {0};

  function new(string name = "lut_ram_rand_seq");
    super.new(name);
  endfunction

  virtual task body();
    lut_ram_seq_item item;

    for(int i = 0; i < seq_length; i++) begin
      item = lut_ram_seq_item::type_id::create("item");

      start_item(item);
      randcase
        //prev-written addrs: bias reads/writes toward addrs that hold real data
        5: begin
          if (!item.randomize() with {
            wr_addr inside { prev_written_addr };
            rd_addr inside { prev_written_addr };
            wr_data dist {
              WORD_ALL_ZEROS                   := 1,
              WORD_ALL_ONES                    := 1,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 5
            };
          }) `uvm_fatal("SEQ", "Failed item.randomize() (prev_written)")
        end

        //corner addresses (first two and last two)
        2: begin
          if (!item.randomize() with {
            wr_addr inside { 0, 1, LUT_RAM_DEPTH-2, LUT_RAM_DEPTH-1 };
            rd_addr inside { 0, 1, LUT_RAM_DEPTH-2, LUT_RAM_DEPTH-1 };
            wr_data dist {
              WORD_ALL_ZEROS                   := 1,
              WORD_ALL_ONES                    := 1,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 5
            };
          }) `uvm_fatal("SEQ", "Failed item.randomize() (corner_addr)")
        end

        //full address range with biased wr_data
        2: begin
          if (!item.randomize() with {
            wr_data dist {
              WORD_ALL_ZEROS                   := 1,
              WORD_ALL_ONES                    := 1,
              [WORD_ALL_ZEROS : WORD_ALL_ONES] :/ 5
            };
          }) `uvm_fatal("SEQ", "Failed item.randomize() (full_range)")
        end
      endcase

      //track addresses weve written to
      if (item.wr_en) prev_written_addr.push_back(item.wr_addr);

      `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
      finish_item(item);
    end

    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

/*
  COVERAGE SAMPLING ASSUMPTIONS:
        - sample() is being called AFTER the DUT signals have been driven onto
          the DUT's input ports and AFTER the combinatorial load_data has had
          time to settle, but BEFORE the new store_data has been clocked into
          memory.

        - NOTE:
            - The covergroup uses state (written, prev_store_byte_sel, prev_addr) to
              collect some of its coverpoints. State is updated in sample().
              If you drive/clock the DUT without calling sample(), update those
              variables manually or coverage will get out of sync.
*/
class data_mem_coverage extends uvm_object;
  `uvm_object_utils(data_mem_coverage);

  data_mem_seq_item item;

  //per-address byte-write history: tracks which bytes have ever been
  //written at each addr (so reads of written bytes can be distinguished)
  byte_sel_t written [word_t];
  byte_sel_t prev_store_byte_sel;
  word_t     prev_addr;

  function new(string name = "data_mem_coverage");
    super.new(name);
    this.cg = new();
    this.reset_state();
  endfunction

  function void sample(data_mem_seq_item item);
    this.item = item;
    cg.sample();
    update_state();
  endfunction

  function void reset_state();
    written.delete();
    prev_store_byte_sel = '0;
    prev_addr   = 'x;
  endfunction

  function void update_state();
    if(!written.exists(item.addr)) begin
      written[item.addr] = item.store_byte_sel;
    end
    else begin
      written[item.addr] |= item.store_byte_sel;
    end
    prev_store_byte_sel = item.store_byte_sel;
    prev_addr   = item.addr;
  endfunction

  function void print_coverage_report();
    real total = cg.get_inst_coverage();
    $display("\n========================================");
    $display("***   data_mem_coverage: %6.2f%%        ***", total);
    $display("========================================");
    if (total < 100.0) begin
      $display("  addr:                                        %6.2f%%", cg.addr.get_coverage());
      $display("  byte_offset:                                 %6.2f%%", cg.byte_offset.get_coverage());
      $display("  store_byte_sel:                                      %6.2f%%", cg.store_byte_sel.get_coverage());
      $display("  store_data:                                     %6.2f%%", cg.store_data.get_coverage());
      $display("  store_byte_sel_x_addr_x_store_data:                     %6.2f%%", cg.store_byte_sel_x_addr_x_store_data.get_coverage());
      $display("  store_byte_sel_x_byte_offset_x_store_data:              %6.2f%%", cg.store_byte_sel_x_byte_offset_x_store_data.get_coverage());
      $display("  back_to_back_write:                          %6.2f%%", cg.back_to_back_write.get_coverage());
      $display("  back_to_back_write_x_byte_offset:            %6.2f%%", cg.back_to_back_write_x_byte_offset.get_coverage());
      $display("  written_bytes:                               %6.2f%%", cg.written_bytes.get_coverage());
      $display("  addr_x_written_bytes:                        %6.2f%%", cg.addr_x_written_bytes.get_coverage());
      $display("  byte_offset_x_written_bytes:                 %6.2f%%", cg.byte_offset_x_written_bytes.get_coverage());
      $display("  load_data:                                     %6.2f%%", cg.load_data.get_coverage());
      $display("  load_data_x_addr:                              %6.2f%%", cg.load_data_x_addr.get_coverage());
      $display("  load_data_x_byte_offset:                       %6.2f%%", cg.load_data_x_byte_offset.get_coverage());
      $display("  read_during_write:                           %6.2f%%", cg.read_during_write.get_coverage());
      $display("  read_during_write_x_addr:                    %6.2f%%", cg.read_during_write_x_addr.get_coverage());
      $display("  read_during_write_x_byte_offset:             %6.2f%%", cg.read_during_write_x_byte_offset.get_coverage());
      $display("  next_cycle_read_after_write:                 %6.2f%%", cg.next_cycle_read_after_write.get_coverage());
      $display("  next_cycle_read_after_write_x_addr:          %6.2f%%", cg.next_cycle_read_after_write_x_addr.get_coverage());
      $display("  next_cycle_read_after_write_x_byte_offset:   %6.2f%%", cg.next_cycle_read_after_write_x_byte_offset.get_coverage());
      $display("========================================\n");
    end
    else begin
      $display("");
    end
  endfunction

  /*==============================  COVERGROUP  =================================*/
  covergroup cg;

    /***************** ADDRESS COVERAGE ****************************/

    //hit each byte of the first and last word in memory
    addr: coverpoint item.addr {
      //first word
      bins first_word_byte_0 = {DATA_MEM_FIRST_ADDR};
      bins first_word_byte_1 = {DATA_MEM_FIRST_ADDR + 1};
      bins first_word_byte_2 = {DATA_MEM_FIRST_ADDR + 2};
      bins first_word_byte_3 = {DATA_MEM_FIRST_ADDR + 3};
      //last word
      bins last_word_byte_0  = {DATA_MEM_LAST_WORD_ADDR};
      bins last_word_byte_1  = {DATA_MEM_LAST_WORD_ADDR + 1};
      bins last_word_byte_2  = {DATA_MEM_LAST_WORD_ADDR + 2};
      bins last_word_byte_3  = {DATA_MEM_LAST_ADDR};

      bins non_corner        = default;
    }

    //hit each byte offset at least once
    byte_offset: coverpoint item.addr[1:0];


    /********************* WRITE COVERAGE *********************/

    //the specific store_byte_sel patterns that rv32i ops generate
    store_byte_sel: coverpoint item.store_byte_sel {
      bins no_write = {4'b0000};   //not writing
      bins sb       = {4'b0001};   //store-byte
      bins sh       = {4'b0011};   //store-halfword
      bins sw       = {4'b1111};   //store-word
      bins others   = default;
    }

    //all 1s and all 0s through store_data
    //  - NOTE: only collect when we are actually writing
    store_data: coverpoint item.store_data
      iff(item.store_byte_sel) {
        bins all_ones    = {WORD_ALL_ONES};
        bins all_zeros   = {WORD_ALL_ZEROS};
        bins non_corners = default;
    }

    //write all 1s and all 0s to each corner addr, with each store_byte_sel pattern
    store_byte_sel_x_addr_x_store_data: cross addr, store_byte_sel, store_data {
      //don't collect the cross when we aren't writing
      ignore_bins no_write_x_store_data = binsof(store_byte_sel.no_write) && binsof(store_data);
    }

    //write all 1s and all 0s at each byte_offset, with each store_byte_sel pattern
    store_byte_sel_x_byte_offset_x_store_data: cross byte_offset, store_byte_sel, store_data {
      ignore_bins no_write_x_store_data = binsof(store_byte_sel.no_write) && binsof(store_data);
    }


    /*********** BACK TO BACK WRITE COVERAGE **********************/

    //back-to-back writes to the same address.
    //  - (item.store_byte_sel & prev_store_byte_sel) bitwise AND picks out which bytes overlap
    //    between consecutive transactions. Writes are byte granular so we bin
    //    each byte lane separately via wildcard bins.
    //  - iff (item.addr == prev_addr): back-to-back only counts when its
    //    actually the same address.
    back_to_back_write: coverpoint (item.store_byte_sel & prev_store_byte_sel)
      iff (item.addr == prev_addr) {
        wildcard bins byte_0 = {4'b???1};
        wildcard bins byte_1 = {4'b??1?};
        wildcard bins byte_2 = {4'b?1??};
        wildcard bins byte_3 = {4'b1???};
    }

    //back-to-back-write functionality from each byte offset
    back_to_back_write_x_byte_offset: cross back_to_back_write, byte_offset;


    /********************* READ COVERAGE *********************/

    //Writes are byte-granular so not every byte in a word will have
    //been written. Only collect read coverage on bytes that have been
    //written -- reading uninitialized data isnt the interesting functionality.
    written_bytes: coverpoint (written[item.addr])
      iff(written.exists(item.addr)) {
        wildcard bins byte_0 = {4'b???1};
        wildcard bins byte_1 = {4'b??1?};
        wildcard bins byte_2 = {4'b?1??};
        wildcard bins byte_3 = {4'b1???};
    }

    //read written bytes out of each corner address
    addr_x_written_bytes: cross addr, written_bytes;

    //read written bytes from each byte offset
    byte_offset_x_written_bytes: cross byte_offset, written_bytes;

    load_data: coverpoint item.load_data {
      bins all_ones    = {WORD_ALL_ONES};
      bins all_zeros   = {WORD_ALL_ZEROS};
      bins non_corners = default;
    }

    //read corner data out of each corner address
    load_data_x_addr: cross load_data, addr;

    //read corner data out of each byte offset
    load_data_x_byte_offset: cross load_data, byte_offset;


    /************** READ DURING WRITE COVERAGE *********************/

    //Reads and writes use the same address, so as long as store_byte_sel != 0 all
    //reads are during a write. Writes are byte granular so we use wildcard
    //bins to make sure we did a read_during_write while each byte was being
    //written.
    read_during_write: coverpoint (item.store_byte_sel) {
      wildcard bins byte_0 = {4'b???1};
      wildcard bins byte_1 = {4'b??1?};
      wildcard bins byte_2 = {4'b?1??};
      wildcard bins byte_3 = {4'b1???};
    }

    //read_during_writes at each corner address
    read_during_write_x_addr: cross read_during_write, addr;

    //read_during_writes at each byte_offset
    read_during_write_x_byte_offset: cross read_during_write, byte_offset;


    /*********  NEXT CYCLE READ AFTER WRITE COVERAGE *********************/

    //reading a write on the clk cycle immediately following the write
    next_cycle_read_after_write: coverpoint prev_store_byte_sel
      iff(item.addr == prev_addr) {
        wildcard bins byte_0 = {4'b???1};
        wildcard bins byte_1 = {4'b??1?};
        wildcard bins byte_2 = {4'b?1??};
        wildcard bins byte_3 = {4'b1???};
    }

    //read_after_write at each corner address
    next_cycle_read_after_write_x_addr: cross next_cycle_read_after_write, addr;

    //read_after_write at each byte_offset
    next_cycle_read_after_write_x_byte_offset: cross next_cycle_read_after_write, byte_offset;
  endgroup
endclass

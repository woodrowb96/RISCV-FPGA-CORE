/*
  COVERAGE SAMPLING ASSUMPTIONS:
        - sample() is being called AFTER the DUT signals have been driven onto
          the DUT's input ports and AFTER the combinatorial rd_data has had
          time to settle, but BEFORE the new wr_data has been clocked into
          memory.

        - NOTE:
            - The covergroup uses written, prev_wr_en and prev_wr_addr to
              collect coverage. These variables are all updated when you call
              sample().
            - If you drive/clock the DUT without calling sample(), manually
              update those state variables or coverage state will get out of
              sync with the test state.
*/
class lut_ram_coverage extends uvm_object;
  `uvm_object_utils(lut_ram_coverage);

  localparam int unsigned MIN_ADDR = 0;
  localparam int unsigned MAX_ADDR = LUT_RAM_DEPTH - 1;

  lut_ram_seq_item item;

  //We want to keep track of some stuff to help us collect coverage
  bit written [lut_ram_addr_t];  //track which addrs have been written to
  logic          prev_wr_en;
  lut_ram_addr_t prev_wr_addr;

  function new(string name = "lut_ram_coverage");
    super.new(name);
    this.cg = new();
    this.reset_state();
  endfunction

  function void sample(lut_ram_seq_item item);
    this.item = item;
    cg.sample();
    update_state(); //update state after we sample
  endfunction

  function void reset_state();
    written.delete();
    prev_wr_en   = '0;
    prev_wr_addr = 'x;
  endfunction

  function void update_state();
    if(item.wr_en) begin
      written[item.wr_addr] = 1;
    end
    prev_wr_en   = item.wr_en;
    prev_wr_addr = item.wr_addr;
  endfunction

  function void print_coverage_report();
    real total = cg.get_inst_coverage();
    $display("\n========================================");
    $display("***   lut_ram_coverage: %6.2f%%        ***", total);
    $display("========================================");
    if (total < 100.0) begin
      $display("  wr_en:                          %6.2f%%", cg.wr_en.get_coverage());
      $display("  wr_addr:                        %6.2f%%", cg.wr_addr.get_coverage());
      $display("  wr_addr_x_wr_en:                %6.2f%%", cg.wr_addr_x_wr_en.get_coverage());
      $display("  back_to_back_writes:            %6.2f%%", cg.back_to_back_writes.get_coverage());
      $display("  wr_data:                        %6.2f%%", cg.wr_data.get_coverage());
      $display("  wr_data_x_wr_addr:              %6.2f%%", cg.wr_data_x_wr_addr.get_coverage());
      $display("  rd_addr:                        %6.2f%%", cg.rd_addr.get_coverage());
      $display("  rd_data:                        %6.2f%%", cg.rd_data.get_coverage());
      $display("  rd_data_x_rd_addr:              %6.2f%%", cg.rd_data_x_rd_addr.get_coverage());
      $display("  read_during_write:              %6.2f%%", cg.read_during_write.get_coverage());
      $display("  next_cycle_read_after_write:    %6.2f%%", cg.next_cycle_read_after_write.get_coverage());
      $display("========================================\n");
    end
    else begin
      $display("");
    end
  endfunction

  /*==============================  COVERGROUP  =================================*/
  covergroup cg;
    /************************** WRITE COVERAGE ************************/
    wr_en: coverpoint item.wr_en {
      bins write    = {1'b1};
      bins no_write = {1'b0};
    }

    wr_addr: coverpoint item.wr_addr {
      bins addr_min            = {MIN_ADDR};
      bins second_addr         = {MIN_ADDR + 1};
      bins second_to_last_addr = {MAX_ADDR - 1};
      bins addr_max            = {MAX_ADDR};
      bins non_corner          = default;
    }

    //we want to write and not write to our corner addresses
    wr_addr_x_wr_en: cross wr_addr, wr_en;

    //we want to write back to back to at least one address
    back_to_back_writes: coverpoint ((item.wr_addr == prev_wr_addr) && (item.wr_en && prev_wr_en)) {
      bins hit = {1};
    }

    //We want to write all 1s and all 0s through the wr_data port
    //  - We only want to collect this coverage when wr_en == 1, i.e. we are writing
    wr_data: coverpoint item.wr_data
      iff(item.wr_en) {
        bins zeros      = {WORD_ALL_ZEROS};
        bins all_ones   = {WORD_ALL_ONES};
        bins non_corner = default;
    }

    //we want to write corner wr_data into corner addresses
    wr_data_x_wr_addr: cross wr_data, wr_addr;


    /*********************** READ COVERAGE ***************************/

    //Note: we only want to collect rd_addr coverage on addresses that have
    //been written into already. Reading unwritten/uninitialized addresses
    //that point to xs doesnt verify much and isnt the functionality we are
    //interested in covering.
    rd_addr: coverpoint item.rd_addr
      iff(written.exists(item.rd_addr)) {
        bins addr_min            = {MIN_ADDR};
        bins second_addr         = {MIN_ADDR + 1};
        bins second_to_last_addr = {MAX_ADDR - 1};
        bins addr_max            = {MAX_ADDR};
        bins non_corner          = default;
    }

    rd_data: coverpoint item.rd_data
      iff(written.exists(item.rd_addr)) {
        bins zeros      = {WORD_ALL_ZEROS};
        bins all_ones   = {WORD_ALL_ONES};
        bins non_corner = default;
    }

    //we want to read corner data out of all corner addresses
    rd_data_x_rd_addr: cross rd_data, rd_addr;

    //Cover reading and writing to the same address during the same transaction
    //  - rd_data will be the OLD data at that address, not the NEW wr_data
    //    about to be clocked in
    //  - NOTE: iff(rd_data != wr_data)
    //      - This functionality is only verifiable when the data already in
    //        the memory is different than the data about to be written in.
    //  - NOTE:
    //      - I dont guard with iff(written). The fact that the rd_addr
    //        might be unwritten doesnt matter here. We dont really care
    //        what is in the memory currently, just that it is not what is
    //        about to get written in.
    read_during_write: coverpoint (item.wr_en && (item.rd_addr == item.wr_addr))
      iff(item.rd_data != item.wr_data) {
        bins hit = {1};
    }

    //We want to cover reading from an address the clk cycle immediately
    //following the clk cycle it got written to.
    //  - Note: SEE the note in tb_reg_file_coverage about the small
    //    verifiability gap with this kind of coverpoint.
    next_cycle_read_after_write: coverpoint ((item.rd_addr == prev_wr_addr) && prev_wr_en) {
      bins hit = {1};
    }
  endgroup
endclass

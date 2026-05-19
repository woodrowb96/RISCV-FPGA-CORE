class lut_ram_seq_item extends uvm_sequence_item;
  `uvm_object_utils(lut_ram_seq_item)

  rand logic          wr_en;    //control
  rand lut_ram_addr_t wr_addr;  //input
  rand lut_ram_addr_t rd_addr;
  rand lut_ram_data_t wr_data;
  lut_ram_data_t      rd_data;  //output

  //$clog2(LUT_RAM_DEPTH) may give more bits than the depth allows
  //(e.g. clog2(1000) = 10 bits -> 0..1023, but legal range is 0..999)
  constraint legal_address_range {
    wr_addr inside {[0:LUT_RAM_DEPTH-1]};
    rd_addr inside {[0:LUT_RAM_DEPTH-1]};
  }

  function new(string name = "lut_ram_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf(
      "wr_en:%b | wr_addr=%0d wr_data=%h | rd_addr=%0d | rd_data=%h",
        wr_en,
        wr_addr, wr_data,
        rd_addr,
        rd_data);
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    lut_ram_seq_item rhs_;

    if (!$cast(rhs_, rhs))
      return 0;

    return (rd_data === rhs_.rd_data);
  endfunction

  /******** NOTE ********/
  //Post_randomizing the MSB is a workaround for a Vivado bug.
  //  - 32 bit signals do not get their MSB randomized by the
  //    constraint solver.
  /***********************/
  function void post_randomize();
    if(!(wr_data inside {WORD_ALL_ZEROS, WORD_ALL_ONES})) begin
      randcase
        1: wr_data[LUT_RAM_WIDTH-1] = 1'b0;
        1: wr_data[LUT_RAM_WIDTH-1] = 1'b1;
      endcase
    end
  endfunction
endclass

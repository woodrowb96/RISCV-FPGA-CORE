class data_mem_seq_item extends uvm_sequence_item;
  `uvm_object_utils(data_mem_seq_item)

  rand byte_sel_t store_byte_sel;   //control
  rand word_t     addr;     //input
  rand word_t     store_data;
  word_t          load_data;  //output

  //memory is byte-addressable and DATA_MEM_LAST_ADDR is the last byte;
  //base addresses near the end will exercise the byte-offset wrap-around
  constraint legal_addr_range {
    addr inside { [DATA_MEM_FIRST_ADDR : DATA_MEM_LAST_ADDR] };
  }

  function new(string name = "data_mem_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf(
      "store_byte_sel:%0b | addr=%0d store_data=%h | load_data=%h",
        store_byte_sel,
        addr, store_data,
        load_data);
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    data_mem_seq_item rhs_;

    if (!$cast(rhs_, rhs))
      return 0;

    return (load_data === rhs_.load_data);
  endfunction

  /******** NOTE ********/
  //Post_randomizing the MSB is a workaround for a Vivado bug.
  //  - 32 bit signals do not get their MSB randomized by the
  //    constraint solver.
  /***********************/
  function void post_randomize();
    if(!(store_data inside {WORD_ALL_ZEROS, WORD_ALL_ONES})) begin
      randcase
        1: store_data[XLEN-1] = 1'b0;
        1: store_data[XLEN-1] = 1'b1;
      endcase
    end
  endfunction
endclass

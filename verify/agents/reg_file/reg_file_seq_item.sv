class reg_file_seq_item extends uvm_sequence_item;
  `uvm_object_utils(reg_file_seq_item)

  rand logic     write_en;     //control
  rand rf_addr_t write_addr;    //input
  rand word_t    write_data;
  rand rf_addr_t read_addr_1;
  rand rf_addr_t read_addr_2;
  word_t         read_data_1; //output
  word_t         read_data_2;

  function new(string name = "reg_file_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf(
      "write_en:%b | write_addr=%d write_data=%h | read_addr_1=%d read_addr_2=%d | read_data_1=%h read_data_2=%h",
        write_en,
        write_addr, write_data,
        read_addr_1, read_addr_2,
        read_data_1, read_data_2);
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    reg_file_seq_item rhs_;

    if (!$cast(rhs_, rhs))
      return 0;

    return (read_data_1 === rhs_.read_data_1 &&
            read_data_2 === rhs_.read_data_2);
  endfunction

  /****************** NOTE *********************************/
  //Post_randomizing the MSB is a workaround for a Vivado bug.
  //  - 32 bit signals do not get their MSB randomized by the
  //    constraint solver.
  /*********************************************************/
  function void post_randomize();
    if(!(write_data inside {WORD_ALL_ZEROS, WORD_ALL_ONES})) begin
      randcase
        1: write_data[XLEN-1] = 1'b0;
        1: write_data[XLEN-1] = 1'b1;
      endcase
    end
  endfunction
endclass

class reg_file_seq_item extends uvm_sequence_item;
  `uvm_object_utils(reg_file_seq_item)

  rand logic     wr_en;     //control
  rand rf_addr_t wr_reg;    //input
  rand word_t    wr_data;
  rand rf_addr_t rd_reg_1;
  rand rf_addr_t rd_reg_2;
  word_t         rd_data_1; //output
  word_t         rd_data_2;

  function new(string name = "reg_file_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf(
      "wr_en:%0b | wr_reg=%0d wr_data=%0h | rd_reg_1=%0d rd_reg_2=%0d | rd_data_1=%0h rd_data_2=%0h",
        wr_en,
        wr_reg, wr_data,
        rd_reg_1, rd_reg_2,
        rd_data_1, rd_data_2);
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    reg_file_seq_item rhs_;

    if (!$cast(rhs_, rhs))
      return 0;

    return (rd_data_1 == rhs_.rd_data_1 &&
            rd_data_2 == rhs_.rd_data_2);
  endfunction

  /****************** NOTE *********************************/
  //Post_randomizing the MSB is a workaround for a Vivado bug.
  //  - 32 bit signals do not get their MSB randomized by the
  //    constraint solver.
  /*********************************************************/
  // function void post_randomize();
  //   if(!(wr_data inside {WORD_ALL_ZEROS, WORD_ALL_ONES})) begin
  //     randcase
  //       1: wr_data[XLEN-1] = 1'b0;
  //       1: wr_data[XLEN-1] = 1'b1;
  //     endcase
  //   end
  // endfunction
endclass

package riscv_32i_control_pkg;

  //select sub bytes in a word
  //for example in data_mem we use it to select which bytes to write
  //i.e: 4'b0000 -> no bytes being written
  //     4'b0010 -> onlyt byte 2 being written
  //     4'b1111 -> the whole word being written
  typedef logic [3:0] byte_sel_t;
endpackage

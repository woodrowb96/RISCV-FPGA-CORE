/*
  Register file module for a riscv rv32i implementation.

Control:
  write_en: active high write enable signal

Input:
  write_addr:  register index we are writing to
  write_data: write data
            - synchronous writes
            - written into write_addr @(posedge clk)

  read_addr_1: index we are reading read_data_1 from
  read_addr_2: index we are reading read_data_2 from

Output:
  read_data_1: data read from read_addr_1
  read_data_2: data read from read_addr_2
              - asynchronous reads

NOTE:
     - Register x0 (reg_file[0]) always returns '0
*/
module reg_file
  import rv32i_defs_pkg::*;
(
  //clk
  input logic clk,

  //control
  input logic write_en,

  //input
  input rf_addr_t write_addr,
  input word_t    write_data,

  input rf_addr_t read_addr_1,
  input rf_addr_t read_addr_2,

  //output
  output word_t read_data_1,
  output word_t read_data_2
);
  /************ REGISTER FILE ***********************/
  word_t reg_file [0:RF_DEPTH-1];
  initial reg_file[X0] = '0; //for sim, to help make assertions easier to write

  /************ SYNCHRONOUS WRITES *******************/
  always_ff @(posedge clk) begin
    if(write_en && (write_addr != X0)) begin //make sure we dont write to x0
      reg_file[write_addr] <= write_data;
    end
  end

  /************ ASYNCHRONOUS READS *******************/
  always_comb begin
    read_data_1 = (read_addr_1 == X0) ? '0 : reg_file[read_addr_1];
    read_data_2 = (read_addr_2 == X0) ? '0 : reg_file[read_addr_2];
  end
endmodule

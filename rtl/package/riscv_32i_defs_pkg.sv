package riscv_32i_defs_pkg;
  //register and word defs
  parameter int XLEN = 32;                //registers are 32 bits wide
  typedef logic [XLEN-1:0] word_t;    //words are 32 bit wide

  //reg file defs
  parameter int RF_DEPTH = 32;        //reg file is 32 registers deep
  parameter int RF_ADDR_WIDTH = 5;    //A reg_file address are 5 bits wide, so we can address all 32 regs
  typedef logic [RF_ADDR_WIDTH-1:0] rf_addr_t;
  parameter rf_addr_t X0 = 5'd0;

  //alu defs
  typedef enum logic[3:0] {
    ALU_AND = 4'b0000,
    ALU_OR  = 4'b0001,
    ALU_ADD = 4'b0010,
    ALU_SUB = 4'b0110
  } alu_op_t;
endpackage

/*
  This module contains typedef and param definitions concerning the rv32i specification.
*/
package rv32i_defs_pkg;
  /*****************  REGISTERS *****************************/
  parameter int unsigned XLEN = 32;   //registers are 32 bits wide

  /*********************  WORD  *****************************/
  typedef logic [XLEN-1:0] word_t;    //words are 32 bit wide

  /*********************  BYTE  *****************************/
  parameter int unsigned BYTE_LEN = 8;
  typedef logic [7:0] byte_t;

  /*****************  REGISTER FILE  *****************************/
  parameter int unsigned RF_DEPTH = 32;
  parameter int unsigned RF_ADDR_WIDTH = 5;

  typedef logic [RF_ADDR_WIDTH-1:0] rf_addr_t;

  parameter rf_addr_t X0 = 5'd0;  //x0 is a special register that always holds '0

  /***************  INSTRUCTION FIELDS ***************************/
  typedef enum logic [6:0] {
    OP_REG    = 7'b0110011,  // R-type ALU
    OP_IMM    = 7'b0010011,  // I-type ALU
    OP_LOAD   = 7'b0000011,  // I-type loads
    OP_STORE  = 7'b0100011,  // S-type stores
    OP_BRANCH = 7'b1100011,  // B-type branches
    OP_LUI    = 7'b0110111,  // U-type
    OP_AUIPC  = 7'b0010111,  // U-type
    OP_JAL    = 7'b1101111,  // J-type
    OP_JALR   = 7'b1100111,  // I-type
    OP_FENCE  = 7'b0001111,  // Implemented as a NOP
    OP_SYSTEM = 7'b1110011   //WILL NOT BE IMPLEMENTED YET
  } opcode_t;

  typedef logic[2:0] f3_t;
  typedef logic[6:0] f7_t;

  /***************** OP_REG F3 AND F7 PARAMS ***********************/
  localparam f3_t F3_ADD_SUB = 3'b000;
  localparam f3_t F3_SLL     = 3'b001;
  localparam f3_t F3_SLT     = 3'b010;
  localparam f3_t F3_SLTU    = 3'b011;
  localparam f3_t F3_XOR     = 3'b100;
  localparam f3_t F3_SRL_SRA = 3'b101;
  localparam f3_t F3_OR      = 3'b110;
  localparam f3_t F3_AND     = 3'b111;

  localparam f7_t F7_ADD = 7'b0000000;
  localparam f7_t F7_SUB = 7'b0100000;
  localparam f7_t F7_SRL = 7'b0000000;
  localparam f7_t F7_SRA = 7'b0100000;

  /***************** OP_IMM F3 AND F7 PARAMS ***********************/
  localparam f3_t F3_ADDI      = 3'b000;
  localparam f3_t F3_SLLI      = 3'b001;
  localparam f3_t F3_SLTI      = 3'b010;
  localparam f3_t F3_SLTIU     = 3'b011;
  localparam f3_t F3_XORI      = 3'b100;
  localparam f3_t F3_SRLI_SRAI = 3'b101;
  localparam f3_t F3_ORI       = 3'b110;
  localparam f3_t F3_ANDI      = 3'b111;

  localparam f7_t F7_SRLI = 7'b0000000;
  localparam f7_t F7_SRAI = 7'b0100000;

  /***************** OP_LOAD F3 AND F7 PARAMS ***********************/
  localparam f3_t F3_LB  = 3'b000;
  localparam f3_t F3_LH  = 3'b001;
  localparam f3_t F3_LW  = 3'b010;
  localparam f3_t F3_LBU = 3'b100;
  localparam f3_t F3_LHU = 3'b101;

  /***************** OP_STORE F3 AND F7 PARAMS ***********************/
  localparam f3_t F3_SB = 3'b000;
  localparam f3_t F3_SH = 3'b001;
  localparam f3_t F3_SW = 3'b010;

  /***************** OP_BRANCH F3 AND F7 PARAMS ***********************/
  localparam f3_t F3_BEQ  = 3'b000;
  localparam f3_t F3_BNE  = 3'b001;
  localparam f3_t F3_BLT  = 3'b100;
  localparam f3_t F3_BGE  = 3'b101;
  localparam f3_t F3_BLTU = 3'b110;
  localparam f3_t F3_BGEU = 3'b111;

endpackage

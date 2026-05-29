/*
  This module contains typedefs and params related to implementation specific control.
*/
package rv32i_control_pkg;
  import rv32i_defs_pkg::*;

  /*********************** BYTE SELECT ************************/
  //select sub bytes in a word
  //for example in data_mem we use it to select which bytes to write
  //i.e: 4'b0000 -> no bytes being written
  //     4'b0010 -> only byte 2 being written
  //     4'b1111 -> the whole word being written
  /***********************************************************/
  typedef logic [3:0] byte_sel_t;

  /***************** ALU CONTROL *******************************/
  //alu operations
  typedef enum logic[3:0] {
    ALU_AND  = 4'b0000,
    ALU_OR   = 4'b0001,
    ALU_XOR  = 4'b0010,
    ALU_ADD  = 4'b0110,
    ALU_SUB  = 4'b0111,
    ALU_SLT  = 4'b1000,
    ALU_SLTU = 4'b1001,
    ALU_SLL  = 4'b1010,
    ALU_SRL  = 4'b1011,
    ALU_SRA  = 4'b1100
  } alu_op_t;

  /************** DATA PATH CONTROL ****************************/
  typedef enum logic [1:0] {
    SRC1_RS1  = 2'b00,
    SRC1_PC   = 2'b01,
    SRC1_ZERO = 2'b10
  } alu_src_sel_1_t;

  typedef enum logic [1:0] {
    SRC2_RS2  = 2'b00,
    SRC2_IMM  = 2'b01,
    SRC2_FOUR = 2'b10
  } alu_src_sel_2_t;

  typedef enum logic {
    WB_MEM = 1'b0,
    WB_ALU = 1'b1
  } wb_sel_t;

  typedef enum logic[2:0] {
    BR_NONE  = 3'd0,
    BR_BEQ   = 3'd1,
    BR_BNE   = 3'd2,
    BR_BLT   = 3'd3,
    BR_BGE   = 3'd4,
    BR_BLTU  = 3'd5,
    BR_BGEU  = 3'd6,
    BR_JUMP  = 3'd7
  } branch_type_t;

  typedef enum logic {
    BTGT_PC  = 1'b0,
    BTGT_RS1 = 1'b1
  } branch_target_src_sel_t;

  typedef enum logic[2:0] {
    LOAD_B  = 3'b000,
    LOAD_H  = 3'b001,
    LOAD_W  = 3'b010,
    LOAD_BU = 3'b011,
    LOAD_HU = 3'b100
  }load_type_t;
endpackage

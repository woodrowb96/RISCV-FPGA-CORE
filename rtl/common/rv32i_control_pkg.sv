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
    ALU_AND = 4'b0000,
    ALU_OR  = 4'b0001,
    ALU_ADD = 4'b0010,
    ALU_SUB = 4'b0110
  } alu_op_t;

  /******************* FLOW CONTROL *************************/

  typedef enum logic {
    RS2 = 1'b0,
    IMM = 1'b1
  } alu_src_sel_2_t;

  typedef enum logic {
    MEM = 1'b0,
    ALU = 1'b1
  } wb_sel_t;

  typedef enum logic[2:0] {
    NONE  = 3'd0,
    BEQ   = 3'd1,
    BNE   = 3'd2,
    BLT   = 3'd3,
    BGE   = 3'd4,
    BLTU  = 3'd5,
    BGEU  = 3'd6,
    JUMP  = 3'd7
  } branch_type_t;

  typedef enum logic {
    PC  = 1'b0,
    RS1 = 1'b1
  } branch_target_src_sel_t;

  /***************** OP_REG F3 PARAMS ***********************/
  localparam f3_t F3_ADD_SUB = 3'b000;
  localparam f3_t F3_SLL     = 3'b001;
  localparam f3_t F3_SLT     = 3'b010;
  localparam f3_t F3_SLTU    = 3'b011;
  localparam f3_t F3_XOR     = 3'b100;
  localparam f3_t F3_SRL_SRA = 3'b101;
  localparam f3_t F3_OR      = 3'b110;
  localparam f3_t F3_AND     = 3'b111;
endpackage

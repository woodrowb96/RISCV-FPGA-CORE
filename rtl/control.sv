module control
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
(
  //input
  input word_t inst_id,

  //output (id_stage control)
  output logic rd_wr_en_id,

  //output (ex_stage control)
  output alu_op_t                alu_op_id,
  output alu_src_sel_2_t         alu_src_sel_2_id,
  output branch_type_t           branch_type_id,
  output branch_target_src_sel_t branch_target_src_sel_id,

  //output (mem_stage control)
  output byte_sel_t mem_store_byte_sel_id,

  //output (wb_stage control)
  output wb_sel_t wb_sel_id
);
  opcode_t opcode;
  f3_t     f3;
  f7_t     f7;

  /********** PARSE INST FIELDS **************/
  assign opcode = opcode_t'(inst_id[6:0]);
  assign f3     = inst_id[14:12];
  assign f7     = inst_id[31:25];

  /*********** DECODE CONTROL ****************/
  always_comb begin
    //default assignments implement a NOP
    rd_wr_en_id              = '0;
    alu_op_id                = ALU_ADD;
    alu_src_sel_2_id         = RS2;
    branch_type_id           = NONE;
    branch_target_src_sel_id = PC;
    mem_store_byte_sel_id    = '0;
    wb_sel_id                = ALU;

    unique case(opcode)
      OP_REG: begin
        rd_wr_en_id = 1'b1; //all OP_REGs will write to the register
        unique case(f3)
          F3_ADD_SUB: begin
            unique case(f7)
              F7_ADD: begin
                alu_op_id = ALU_ADD;
              end
              F7_SUB: begin
                alu_op_id = ALU_SUB;
              end
            endcase
          end
          F3_SLL: begin
            alu_op_id = ALU_SLL;
          end
          F3_SLT: begin
            alu_op_id = ALU_SLT;
          end
          F3_SLTU: begin
            alu_op_id = ALU_SLTU;
          end
          F3_XOR: begin
            alu_op_id = ALU_XOR;
          end
          F3_SRL_SRA: begin
            unique case(f7)
              F7_SRL: begin
                alu_op_id = ALU_SRL;
              end
              F7_SRA: begin
                alu_op_id = ALU_SRA;
              end
            endcase
          end
          F3_OR: begin
            alu_op_id = ALU_OR;
          end
          F3_AND: begin
            alu_op_id = ALU_AND;
          end
        endcase
      end
      OP_IMM: begin
        rd_wr_en_id      = 1'b1; //all OP_IMM will write to the register
        alu_src_sel_2_id = IMM;  //all OP_IMM need to source from the immediate
        unique case(f3)
          F3_ADDI: begin
            alu_op_id = ALU_ADD;
          end
          F3_SLLI: begin
            alu_op_id = ALU_SLL;
          end
          F3_SLTI: begin
            alu_op_id = ALU_SLT;
          end
          F3_SLTIU: begin
            alu_op_id = ALU_SLTU;
          end
          F3_XORI: begin
            alu_op_id = ALU_XOR;
          end
          F3_SRLI_SRAI: begin
            unique case(f7)
              F7_SRLI: begin
                alu_op_id = ALU_SRL;
              end
              F7_SRAI: begin
                alu_op_id = ALU_SRA;
              end
            endcase
          end
          F3_ORI: begin
            alu_op_id = ALU_OR;
          end
          F3_ANDI: begin
            alu_op_id = ALU_AND;
          end
        endcase
      end
      OP_LOAD: begin
      end
      OP_STORE: begin
      end
      OP_BRANCH:begin
      end
      OP_LUI: begin
      end
      OP_AUIPC: begin
      end
      OP_JAL: begin
      end
      OP_JALR: begin
      end
      OP_FENCE: begin
      //fence is implemented as a NOP
      end
      OP_SYSTEM: begin
      //NOT IMPLEMENTED YET
      end
    endcase
  end
endmodule

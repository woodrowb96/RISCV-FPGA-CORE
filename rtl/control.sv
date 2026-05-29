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
  output alu_src_sel_1_t         alu_src_sel_1_id,
  output alu_src_sel_2_t         alu_src_sel_2_id,
  output branch_type_t           branch_type_id,
  output branch_target_src_sel_t branch_target_src_sel_id,

  //output (mem_stage control)
  output byte_sel_t  mem_store_byte_sel_id,
  output load_type_t mem_load_type_id,

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
    alu_src_sel_1_id         = SRC1_RS1;
    alu_src_sel_2_id         = RS2;
    branch_type_id           = NONE;
    branch_target_src_sel_id = PC;
    mem_store_byte_sel_id    = '0;
    mem_load_type_id         = LOAD_B;
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
        rd_wr_en_id      = 1'b1;    //all OP_LOAD will write to the register
        alu_src_sel_2_id = IMM;     //all OP_LOAD need to source from the immediate
        alu_op_id        = ALU_ADD; //all OP_LOAD need to use the alu add to comp the addr
        wb_sel_id        = MEM;     //all OP_LOAD need to write back from data_mem
        unique case(f3)
          F3_LB: begin
            mem_load_type_id = LOAD_B;
          end
          F3_LH: begin
            mem_load_type_id = LOAD_H;
          end
          F3_LW: begin
            mem_load_type_id = LOAD_W;
          end
          F3_LBU: begin
            mem_load_type_id = LOAD_BU;
          end
          F3_LHU: begin
            mem_load_type_id = LOAD_HU;
          end
        endcase
      end
      OP_STORE: begin
        alu_op_id        = ALU_ADD; //OP_STORE needs to add in the alu to calc addr
        alu_src_sel_2_id = IMM;     //OP_STORE addr calc needs the imm
        unique case(f3)
          F3_SB: begin
            mem_store_byte_sel_id = 4'b0001;
          end
          F3_SH: begin
            mem_store_byte_sel_id = 4'b0011;
          end
          F3_SW: begin
            mem_store_byte_sel_id = 4'b1111;
          end
        endcase
      end
      OP_BRANCH:begin
        branch_target_src_sel_id = PC;    //Branches use PC to calc the target address
        unique case(f3)
          F3_BEQ: begin
            branch_type_id = BEQ;
          end
          F3_BNE: begin
            branch_type_id = BNE;
          end
          F3_BLT: begin
            branch_type_id = BLT;
          end
          F3_BGE: begin
            branch_type_id = BGE;
          end
          F3_BLTU: begin
            branch_type_id = BLTU;
          end
          F3_BGEU: begin
            branch_type_id = BGEU;
          end
        endcase
      end
      OP_LUI: begin
        rd_wr_en_id      = 1'b1;      //We need to write the immediate back to rd
        alu_src_sel_1_id = SRC1_ZERO; //ADD zero to the immediate so that it gets written back
        alu_src_sel_2_id = IMM;
        alu_op_id        = ALU_ADD;
        wb_sel_id        = ALU;      //The imm is getting passed through the alu and written back
      end
      OP_AUIPC: begin
        rd_wr_en_id      = 1'b1;      //We need to write the immediate back to rd
        alu_src_sel_1_id = SRC1_PC;   //ADD PC to the immediate
        alu_src_sel_2_id = IMM;
        alu_op_id        = ALU_ADD;
        wb_sel_id        = ALU;       //Write pc + imm back to rd
      end
      OP_JAL: begin
        rd_wr_en_id              = 1'b1; //Need to write pc + 4 back to rd
        alu_op_id                = ALU_ADD;
        alu_src_sel_1_id         = SRC1_PC;
        alu_src_sel_2_id         = FOUR;
        branch_type_id           = JUMP;
        branch_target_src_sel_id = PC;    //Target address is PC + IMM
        wb_sel_id                = ALU;
      end
      OP_JALR: begin
        rd_wr_en_id              = 1'b1;    //Need to write pc + 4 back to rd
        alu_op_id                = ALU_ADD;
        alu_src_sel_1_id         = SRC1_PC;
        alu_src_sel_2_id         = FOUR;
        branch_type_id           = JUMP;
        branch_target_src_sel_id = RS1;    //Target address is RS1 + IMM
        wb_sel_id                = ALU;
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

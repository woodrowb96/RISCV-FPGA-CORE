class riscv_inst extends uvm_object;
  rand opcode_t     opcode;
  rand rf_addr_t    rs1, rs2, rd;
  rand f3_t         f3;
  rand f7_t         f7;
  rand logic [31:0] imm;
  inst_label_t      inst_label; //the decoded inst label (i.e. ADD,JAL,FENCE ...) set during post_rand

  `uvm_object_utils_begin(riscv_inst)
    `uvm_field_enum(opcode_t, opcode, UVM_DEFAULT)
    `uvm_field_int (rs1, UVM_DEFAULT)
    `uvm_field_int (rs2, UVM_DEFAULT)
    `uvm_field_int (rd,  UVM_DEFAULT)
    `uvm_field_int (f3,  UVM_DEFAULT)
    `uvm_field_int (f7,  UVM_DEFAULT)
    `uvm_field_int (imm, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end

  /***********************************************************************************/
  /************************** CONSTRAINTS *******************************************/
  /***********************************************************************************/
  constraint valid_f3_f7 {
    if (opcode == OP_REG) {
      f3 inside {F3_ADD_SUB, F3_SLL, F3_SLT, F3_SLTU, F3_XOR, F3_SRL_SRA, F3_OR, F3_AND};
      if      (f3 == F3_ADD_SUB) f7 inside {F7_ADD, F7_SUB};
      else if (f3 == F3_SRL_SRA) f7 inside {F7_SRL, F7_SRA};
      else                       f7 == '0;
    }

    if (opcode == OP_IMM) {
      f3 inside {F3_ADDI, F3_SLLI, F3_SLTI, F3_SLTIU, F3_XORI, F3_SRLI_SRAI, F3_ORI, F3_ANDI};
      if      (f3 == F3_SRLI_SRAI) f7 inside {F7_SRLI, F7_SRAI};
      else if (f3 == F3_SLLI)      f7 == '0;
    }

    if (opcode == OP_LOAD)   f3 inside {F3_LB, F3_LH, F3_LW, F3_LBU, F3_LHU};
    if (opcode == OP_STORE)  f3 inside {F3_SB, F3_SH, F3_SW};
    if (opcode == OP_BRANCH) f3 inside {F3_BEQ, F3_BNE, F3_BLT, F3_BGE, F3_BLTU, F3_BGEU};
    if (opcode == OP_JALR)   f3 == 3'b000;
    if (opcode == OP_FENCE)  f3 == 3'b000;
    if (opcode == OP_SYSTEM) f3 == 3'b000;
  }

  constraint valid_imm {
    if (opcode inside {OP_IMM, OP_LOAD, OP_STORE, OP_JALR}) {
      imm[31:12] == {20{imm[11]}};   // S-type: sign-extend imm[11]
    }

    if(opcode == OP_IMM && f3 inside {F3_SLLI, F3_SRLI_SRAI}) {
      //per spec we shift using only the lowest 4 bits
      //the upper 7 bits are set to f7
      imm[11:5] == f7;
    }

    if (opcode == OP_BRANCH) {
      imm[31:13] == {19{imm[12]}};   // B-type: sign-extend imm[12]
      imm[0]     == '0;              //lowest bit is 0
    }

    if (opcode == OP_JAL) {
      imm[31:21] == {11{imm[20]}};   // J-type: sign-extend imm[20]
      imm[0]     == '0;              //lowest bit is 0
    }

    if (opcode inside {OP_LUI, OP_AUIPC}) {
      imm[11:0] == '0;               // U-type: lowest 12 bits are zero
    }
  }

  /***********************************************************************************/
  /******************************** METHODS *******************************************/
  /***********************************************************************************/
  function new(string name = "riscv_inst");
    super.new(name);
  endfunction

  function void decode_inst_label();
    inst_label = INST_INVALID;

    unique case(opcode)
      OP_REG: begin
        unique case(f3)
          F3_ADD_SUB: begin
            if     (f7 == F7_ADD) inst_label = INST_ADD;
            else if(f7 == F7_SUB) inst_label = INST_SUB;
          end
          F3_SLL:                 inst_label = INST_SLL;
          F3_SLT:                 inst_label = INST_SLT;
          F3_SLTU:                inst_label = INST_SLTU;
          F3_XOR:                 inst_label = INST_XOR;
          F3_SRL_SRA: begin
            if     (f7 == F7_SRL) inst_label = INST_SRL;
            else if(f7 == F7_SRA) inst_label = INST_SRA;
          end
          F3_OR:                  inst_label = INST_OR;
          F3_AND:                 inst_label = INST_AND;
        endcase
      end
      OP_IMM: begin
        unique case(f3)
          F3_ADDI:                 inst_label = INST_ADDI;
          F3_SLLI:                 inst_label = INST_SLLI;
          F3_SLTI:                 inst_label = INST_SLTI;
          F3_SLTIU:                inst_label = INST_SLTIU;
          F3_XORI:                 inst_label = INST_XORI;
          F3_SRLI_SRAI: begin
            if     (f7 == F7_SRLI) inst_label = INST_SRLI;
            else if(f7 == F7_SRAI) inst_label = INST_SRAI;
          end
          F3_ORI:                  inst_label = INST_ORI;
          F3_ANDI:                 inst_label = INST_ANDI;
        endcase
      end
      OP_LOAD: begin
        unique case(f3)
          F3_LB:  inst_label = INST_LB;
          F3_LH:  inst_label = INST_LH;
          F3_LW:  inst_label = INST_LW;
          F3_LBU: inst_label = INST_LBU;
          F3_LHU: inst_label = INST_LHU;
        endcase
      end
      OP_STORE: begin
        unique case(f3)
          F3_SB: inst_label = INST_SB;
          F3_SH: inst_label = INST_SH;
          F3_SW: inst_label = INST_SW;
        endcase
      end
      OP_BRANCH: begin
        unique case(f3)
          F3_BEQ:  inst_label = INST_BEQ;
          F3_BNE:  inst_label = INST_BNE;
          F3_BLT:  inst_label = INST_BLT;
          F3_BGE:  inst_label = INST_BGE;
          F3_BLTU: inst_label = INST_BLTU;
          F3_BGEU: inst_label = INST_BGEU;
        endcase
      end
      OP_LUI:    inst_label = INST_LUI;
      OP_AUIPC:  inst_label = INST_AUIPC;
      OP_JAL:    inst_label = INST_JAL;
      OP_JALR:   inst_label = INST_JALR;
      OP_FENCE:  inst_label = INST_FENCE;
      OP_SYSTEM: inst_label = INST_ECALL; //Not implemeneted yet
    endcase
  endfunction

  function void post_randomize();
    decode_inst_label();
  endfunction

  function word_t to_word();
    unique case(opcode)
      OP_REG:           return {f7, rs2, rs1, f3, rd, opcode};
      OP_IMM: begin
        if(f3 inside {F3_SLLI, F3_SRLI_SRAI})
                        return {f7, imm[4:0], rs1, f3, rd, opcode};
        else
                        return {imm[11:0], rs1, f3, rd, opcode};
      end
      OP_LOAD, OP_JALR: return {imm[11:0], rs1, f3, rd, opcode};
      OP_STORE:         return {imm[11:5], rs2, rs1, f3, imm[4:0], opcode};
      OP_BRANCH:        return {imm[12], imm[10:5], rs2, rs1, f3, imm[4:1], imm[11], opcode};
      OP_LUI, OP_AUIPC: return {imm[31:12], rd, opcode};
      OP_JAL:           return {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
      OP_FENCE:         return {25'b0, opcode}; //Both FENCE and SYSTEM are NOPs currently
      OP_SYSTEM:        return {25'b0, opcode};
      default:          return '0;
    endcase
  endfunction

  function void from_word(word_t w);
    opcode = opcode_t'(w[6:0]);
    rd     = w[11:7];
    f3     = w[14:12];
    rs1    = w[19:15];
    rs2    = w[24:20];
    f7     = w[31:25];

    unique case (opcode)
      OP_REG:                   imm = '0;
      OP_IMM, OP_LOAD, OP_JALR: imm = {{20{w[31]}}, w[31:20]};
      OP_STORE:                 imm = {{20{w[31]}}, w[31:25], w[11:7]};
      OP_BRANCH:                imm = {{19{w[31]}}, w[31], w[7], w[30:25], w[11:8], 1'b0};
      OP_LUI, OP_AUIPC:         imm = {w[31:12], 12'b0};
      OP_JAL:                   imm = {{11{w[31]}}, w[31], w[19:12], w[20], w[30:21], 1'b0};
      OP_FENCE, OP_SYSTEM:      imm = '0;
      default:                  imm = '0;
    endcase

    decode_inst_label();
  endfunction

  //Strip INST_ label from inst_label enum and return the remaining riscv
  //mnemonic as a string (i.e. INST_ADDI -> ADDI)
  function string mnemonic();
    string n = inst_label.name();
    return n.substr(5, n.len()-1);
  endfunction

  virtual function string convert2string();
    string asm;
    unique case(opcode)
      OP_REG:    asm = $sformatf("%s x%0d, x%0d, x%0d", mnemonic(), rd,  rs1, rs2);
      OP_IMM: begin
        unique case(f3)
          F3_ADDI, F3_SLTI, F3_SLTIU:
                 asm = $sformatf("%s x%0d, x%0d, %0d",   mnemonic(), rd, rs1, $signed(imm[11:0]));
          F3_XORI, F3_ORI, F3_ANDI:
                 asm = $sformatf("%s x%0d, x%0d, 0x%0h", mnemonic(), rd, rs1, imm[11:0]);
          F3_SLLI, F3_SRLI_SRAI:
                 asm = $sformatf("%s x%0d, x%0d, %0d",   mnemonic(), rd, rs1, imm[4:0]);
        endcase
      end
      OP_LOAD:   asm = $sformatf("%s x%0d, %0d(x%0d)", mnemonic(), rd,  $signed(imm[11:0]), rs1);
      OP_STORE:  asm = $sformatf("%s x%0d, %0d(x%0d)", mnemonic(), rs2, $signed(imm[11:0]), rs1);
      OP_BRANCH: asm = $sformatf("%s x%0d, x%0d, %0d", mnemonic(), rs1, rs2, $signed(imm[12:0]));
      OP_LUI,
      OP_AUIPC:  asm = $sformatf("%s x%0d, 0x%0h",     mnemonic(), rd,  imm[31:12]);
      OP_JAL:    asm = $sformatf("%s x%0d, %0d",       mnemonic(), rd,  $signed(imm[20:0]));
      OP_JALR:   asm = $sformatf("%s x%0d, x%0d, %0d", mnemonic(), rd,  rs1, $signed(imm[11:0]));
      OP_FENCE,
      OP_SYSTEM: asm = mnemonic();
      default:   asm = $sformatf("INVALID_OPCODE(%0h)", opcode);
    endcase
    return $sformatf("%s  [0x%08h]", asm, to_word());
  endfunction

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    riscv_inst rhs_;

    if(!$cast(rhs_, rhs))
      return 0;

    return this.to_word() == rhs_.to_word();
  endfunction
endclass

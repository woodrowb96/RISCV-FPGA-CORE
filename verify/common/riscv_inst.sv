class riscv_inst extends uvm_object;
  rand opcode_t     opcode;
  rand rf_addr_t    rs1, rs2, rd;
  rand f3_t         f3;
  rand f7_t         f7;
  rand logic [31:0] imm;

  `uvm_object_utils_begin(riscv_inst)
    `uvm_field_enum(opcode_t, opcode, UVM_DEFAULT)
    `uvm_field_int (rs1, UVM_DEFAULT)
    `uvm_field_int (rs2, UVM_DEFAULT)
    `uvm_field_int (rd,  UVM_DEFAULT)
    `uvm_field_int (f3,  UVM_DEFAULT)
    `uvm_field_int (f7,  UVM_DEFAULT)
    `uvm_field_int (imm, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end

  constraint valid_f3_f7 {
    opcode == OP_REG -> f3 inside {F3_ADD_SUB, F3_SLL, F3_SLT, F3_SLTU, F3_XOR,
                                    F3_SRL_SRA, F3_OR, F3_AND};
    opcode == OP_REG && f3 == F3_ADD_SUB -> f7 inside {F7_ADD, F7_SUB};
    opcode == OP_REG && f3 == F3_SRL_SRA -> f7 inside {F7_SRL, F7_SRA};
    opcode == OP_REG && !(f3 inside {F3_ADD_SUB, F3_SRL_SRA}) -> f7 == '0;

    opcode == OP_IMM -> f3 inside {F3_ADDI, F3_SLLI, F3_SLTI, F3_SLTIU, F3_XORI,
                                    F3_SRLI_SRAI, F3_ORI, F3_ANDI};
    opcode == OP_IMM && f3 == F3_SRLI_SRAI -> f7 inside {F7_SRLI, F7_SRAI};
    opcode == OP_IMM && f3 == F3_SLLI -> f7 == '0;

    opcode == OP_LOAD -> f3 inside {F3_LB, F3_LH, F3_LW, F3_LBU, F3_LHU};

    opcode == OP_STORE -> f3 inside {F3_SB, F3_SH, F3_SW};

    opcode == OP_BRANCH -> f3 inside {F3_BEQ, F3_BNE, F3_BLT, F3_BGE, F3_BLTU, F3_BGEU};

    opcode == OP_JALR -> f3 == 3'b00;

    opcode == OP_FENCE -> f3 == 3'b00;

    opcode == OP_SYSTEM -> f3 == 3'b00;
  }

  constraint valid_imm {
    opcode == OP_BRANCH -> imm[0] == '0;
    opcode == OP_JAL    -> imm[0] == '0;
  }

  function new(string name = "riscv_inst");
    super.new(name);
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
endclass

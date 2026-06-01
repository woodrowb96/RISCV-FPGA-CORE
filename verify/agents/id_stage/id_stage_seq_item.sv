class id_stage_seq_item extends uvm_sequence_item;
  rand logic      rd_wr_en_wb; //control
  rand riscv_inst inst_if;     //input
  rand word_t     pc_if;
  rand word_t     rd_data_wb;
  word_t          pc_id;       //output
  word_t          rs1_data_id;
  word_t          rs2_data_id;
  word_t          imm_id;

  `uvm_object_utils_begin(id_stage_seq_item)
    `uvm_field_int   (rd_wr_en_wb, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_object(inst_if,     UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_int   (pc_if,       UVM_DEFAULT | UVM_NOCOMPARE | UVM_HEX)
    `uvm_field_int   (rd_data_wb,  UVM_DEFAULT | UVM_NOCOMPARE | UVM_HEX)
    `uvm_field_int   (pc_id,       UVM_DEFAULT | UVM_HEX)
    `uvm_field_int   (rs1_data_id, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int   (rs2_data_id, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int   (imm_id,      UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end

  function new(string name = "id_stage_seq_item");
    super.new(name);
    inst_if = riscv_inst::type_id::create("inst_if");
  endfunction

  virtual function string convert2string();
    return $sformatf({
      "CTRL: rd_wr_en_wb=%b\n",
      "IN:   inst_if=%s | pc_if=%h rd_data_wb=%h\n",
      "OUT:  pc_id=%h rs1_data_id=%h rs2_data_id=%h imm_id=%h"},
       rd_wr_en_wb, inst_if.convert2string(), pc_if, rd_data_wb, pc_id, rs1_data_id, rs2_data_id, imm_id);
  endfunction
endclass

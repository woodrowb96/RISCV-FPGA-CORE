class id_stage_ref_model extends uvm_object;
  `uvm_object_utils(id_stage_ref_model)

  reg_file_ref_model ref_reg_file;
  imm_gen_ref_model  ref_imm_gen;
  word_t             ref_pc_id;
  word_t             ref_imm_id;
  word_t             ref_rs1_data_id;
  word_t             ref_rs2_data_id;

  function new(string name = "id_stage_ref_model");
    super.new(name);
    ref_reg_file = reg_file_ref_model::type_id::create("ref_reg_file");
    ref_imm_gen  = imm_gen_ref_model::type_id::create("ref_imm_gen");
  endfunction

  function void predict(id_stage_seq_item item);
    ref_pc_id       = item.pc_if;
    ref_imm_id      = ref_imm_gen.compute(item.inst_if.to_word());
    ref_rs1_data_id = ref_reg_file.read(item.inst_if.rs1);
    ref_rs2_data_id = ref_reg_file.read(item.inst_if.rs2);
  endfunction

  function void update(id_stage_seq_item item);
    if(item.rd_wr_en_wb) begin
      ref_reg_file.write(item.inst_if.rd, item.rd_data_wb);
    end
  endfunction
endclass

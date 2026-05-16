class imm_gen_rand_seq extends imm_gen_base_seq;
  `uvm_object_utils(imm_gen_rand_seq);

  function new(string name = "imm_gen_rand_seq");
    super.new(name);
  endfunction

  /******** NOTE ********/
  //Vivado seg faults on inline constraints over bit slices (e.g. inst[6:0]
  //inside {...})
  //
  //As a workaround I am randomizing the item at the top, then using randcases
  //to randomize the op_codes and encoded immediates
  /***********************/

  virtual task body();
    imm_gen_seq_item item;

    for(int i = 0; i < seq_length; i++) begin
      item = imm_gen_seq_item::type_id::create("item");

      start_item(item);
      if (!item.randomize())
        `uvm_fatal("SEQ", "Failed item.randomize()")

      //choose a format type and override opcode + (optionally) encoded immediate
      randcase
        //base: leave the random valid opcode picked by item.randomize()
        1: ;

        //I-type
        1: begin
          randcase
            1: item.inst[6:0] = OP_IMM;
            1: item.inst[6:0] = OP_LOAD;
            1: item.inst[6:0] = OP_JALR;
          endcase
          randcase
            1: ;  //leave the encoded imm random
            1: item.inst[30:20] = IMM_11_ALL_ZEROS;
            1: item.inst[30:20] = IMM_11_ALL_ONES;
          endcase
        end

        //S-type
        1: begin
          item.inst[6:0] = OP_STORE;
          randcase
            1: ;
            1: {item.inst[30:25], item.inst[11:7]} = IMM_11_ALL_ZEROS;
            1: {item.inst[30:25], item.inst[11:7]} = IMM_11_ALL_ONES;
            1: {item.inst[30:25], item.inst[11:7]} = IMM_11_ALT_55;
            1: {item.inst[30:25], item.inst[11:7]} = IMM_11_ALT_AA;
          endcase
        end

        //B-type
        1: begin
          item.inst[6:0] = OP_BRANCH;
          randcase
            1: ;
            1: {item.inst[7], item.inst[30:25], item.inst[11:8]} = IMM_11_ALL_ZEROS;
            1: {item.inst[7], item.inst[30:25], item.inst[11:8]} = IMM_11_ALL_ONES;
            1: {item.inst[7], item.inst[30:25], item.inst[11:8]} = IMM_11_ALT_55;
            1: {item.inst[7], item.inst[30:25], item.inst[11:8]} = IMM_11_ALT_AA;
          endcase
        end

        //U-type
        1: begin
          randcase
            1: item.inst[6:0] = OP_LUI;
            1: item.inst[6:0] = OP_AUIPC;
          endcase
          randcase
            1: ;
            1: item.inst[31:12] = IMM_20_ALL_ZEROS;
            1: item.inst[31:12] = IMM_20_ALL_ONES;
          endcase
        end

        //J-type
        1: begin
          item.inst[6:0] = OP_JAL;
          randcase
            1: ;
            1: {item.inst[19:12], item.inst[20], item.inst[30:21]} = IMM_19_ALL_ZEROS;
            1: {item.inst[19:12], item.inst[20], item.inst[30:21]} = IMM_19_ALL_ONES;
            1: {item.inst[19:12], item.inst[20], item.inst[30:21]} = IMM_19_ALT_55;
            1: {item.inst[19:12], item.inst[20], item.inst[30:21]} = IMM_19_ALT_AA;
          endcase
        end
      endcase

      `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
      finish_item(item);
    end

    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

class if_stage_ref_model extends uvm_object;
  `uvm_object_utils(if_stage_ref_model)

  inst_mem_ref_model ref_inst_mem;
  word_t             ref_pc;

  function new(string name = "if_stage_ref_model");
    super.new(name);
    ref_inst_mem = inst_mem_ref_model::type_id::create("ref_inst_mem");
    this.reset();
  endfunction

  //load the program file into the reference inst_mem
  function void load_program(string program_file);
    ref_inst_mem.load_program(program_file);
  endfunction

  function void reset();
    ref_pc = PC_RESET;
  endfunction

  function word_t fetch_inst();
    return ref_inst_mem.read(ref_pc);
  endfunction

  function void update(if_stage_seq_item item);
    case(item.branch)
      0: begin
      //Dont take branch
        ref_pc = ref_pc + 'd4;
      end
      1: begin
      //take the branch
        if(item.branch_target[1:0] != 2'b00) begin
          $warning("[IF_STAGE_REF_MODEL]: misaligned branch_target: branch_target:%0d",
            item.branch_target);
        end

        if(item.branch_target >= (INST_MEM_DEPTH * 4)) begin
          $warning("[IF_STAGE_REF_MODEL]: out of bounds branch_target: branch_target:%0d",
            item.branch_target);
        end

        ref_pc = item.branch_target;
      end
      default: begin
      //invalid branch
      //this is undefined behavior in the rtl, so set ref_pc to x's and print an error
        ref_pc = 'x;
        $error("[IF_STAGE_REF_MODEL]: invalid branch, branch:%b", item.branch);
      end
    endcase
  endfunction
endclass

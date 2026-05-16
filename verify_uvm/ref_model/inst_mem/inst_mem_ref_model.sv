/*
  inst_mem reference model.
  - Loads the program file via load_program() (called by the scoreboard).
  - read() mirrors the RTL's OOB-wrap and misaligned-round-down behavior.
*/
class inst_mem_ref_model extends uvm_object;
  `uvm_object_utils(inst_mem_ref_model);

  word_t ref_inst_rom [int unsigned];

  function new(string name = "inst_mem_ref_model");
    super.new(name);
  endfunction

  //load the program file into the reference rom
  function void load_program(string program_file);
    string line;
    int index = 0;
    word_t data;
    int fd;

    fd = $fopen(program_file, "r");
    if(!fd) begin
      $fatal(1, "[INST_MEM_REF_MODEL]: Failed to open %s", program_file);
    end

    while($fgets(line, fd) != 0) begin
      if($sscanf(line, "%h", data) == 1) begin
        ref_inst_rom[index] = data;
        index++;
      end
    end

    $fclose(fd);
  endfunction

  function automatic word_t read(word_t inst_addr);
    int unsigned ref_inst_addr = inst_addr >> 2; //drop the byte offset

    if(inst_addr[1:0] != 2'b00) begin
      $warning("[INST_MEM_REF_MODEL]: misaligned read: inst_addr:%0d", inst_addr);
    end

    //manually wrap out of bounds addresses
    if(ref_inst_addr >= INST_MEM_DEPTH) begin
      $warning("[INST_MEM_REF_MODEL]: out of bound read: depth:%0d, inst_addr:%0d",
                  INST_MEM_DEPTH, inst_addr);
      ref_inst_addr = ref_inst_addr % INST_MEM_DEPTH;
    end

    return ref_inst_rom[ref_inst_addr];
  endfunction
endclass

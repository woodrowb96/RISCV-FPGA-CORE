/*
  NOTE: Out Of Bounds Access
    - The rtl silently wraps out-of-bounds reads/writes to the start of memory.
      This reference model mirrors that behavior via modular arithmetic on the
      byte indices.
*/
class data_mem_ref_model extends uvm_object;
  `uvm_object_utils(data_mem_ref_model);

  //byte-addressable so total byte count is DEPTH(words) * 4
  localparam int unsigned REF_MEM_DEPTH = DATA_MEM_DEPTH * 4;
  typedef logic [$clog2(REF_MEM_DEPTH)-1:0] ref_mem_addr_t;

  byte_t mem [0:REF_MEM_DEPTH-1];

  function new(string name = "data_mem_ref_model");
    super.new(name);
  endfunction

  function word_t read(word_t addr);
    //add the byte offset to each byte, wrap via % to mirror the RTL's
    //silent OOB wrap, then truncate to ref_mem_addr_t width
    ref_mem_addr_t byte_3 = ref_mem_addr_t'((addr + 'd3) % REF_MEM_DEPTH);
    ref_mem_addr_t byte_2 = ref_mem_addr_t'((addr + 'd2) % REF_MEM_DEPTH);
    ref_mem_addr_t byte_1 = ref_mem_addr_t'((addr + 'd1) % REF_MEM_DEPTH);
    ref_mem_addr_t byte_0 = ref_mem_addr_t'((addr + 'd0) % REF_MEM_DEPTH);

    return {mem[byte_3], mem[byte_2], mem[byte_1], mem[byte_0]};
  endfunction

  function void update(data_mem_seq_item item);
    ref_mem_addr_t byte_3 = ref_mem_addr_t'((item.addr + 'd3) % REF_MEM_DEPTH);
    ref_mem_addr_t byte_2 = ref_mem_addr_t'((item.addr + 'd2) % REF_MEM_DEPTH);
    ref_mem_addr_t byte_1 = ref_mem_addr_t'((item.addr + 'd1) % REF_MEM_DEPTH);
    ref_mem_addr_t byte_0 = ref_mem_addr_t'((item.addr + 'd0) % REF_MEM_DEPTH);

    //look at store_byte_sel and write the proper bytes
    if(item.store_byte_sel[3]) mem[byte_3] = item.store_data[31:24];
    if(item.store_byte_sel[2]) mem[byte_2] = item.store_data[23:16];
    if(item.store_byte_sel[1]) mem[byte_1] = item.store_data[15:8];
    if(item.store_byte_sel[0]) mem[byte_0] = item.store_data[7:0];
  endfunction
endclass

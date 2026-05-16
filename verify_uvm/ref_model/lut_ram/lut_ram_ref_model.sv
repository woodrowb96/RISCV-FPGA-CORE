/*
  NOTE: Out of bounds behavior is undefined in the rtl, so the reference
        model issues a warning and then does the read/write anyway with
        whatever the undefined behavior happens to be.
*/
class lut_ram_ref_model extends uvm_object;
  `uvm_object_utils(lut_ram_ref_model);

  lut_ram_data_t mem [0:LUT_RAM_DEPTH-1];

  function new(string name = "lut_ram_ref_model");
    super.new(name);
  endfunction

  function lut_ram_data_t read(lut_ram_addr_t rd_addr);
    if(rd_addr >= LUT_RAM_DEPTH) begin
      $warning("LUT_REF_MODEL: out of bound read depth:%0d rd_addr:%0d", LUT_RAM_DEPTH, rd_addr);
    end
    return mem[rd_addr];
  endfunction

  function void write(lut_ram_addr_t wr_addr, lut_ram_data_t wr_data);
    if(wr_addr >= LUT_RAM_DEPTH) begin
      $warning("LUT_REF_MODEL: out of bound write depth:%0d wr_addr:%0d", LUT_RAM_DEPTH, wr_addr);
    end
    mem[wr_addr] = wr_data;
  endfunction

  function void update(lut_ram_seq_item item);
    if(item.wr_en) begin
      write(item.wr_addr, item.wr_data);
    end
  endfunction
endclass

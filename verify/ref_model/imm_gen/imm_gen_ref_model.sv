//Import the c++ ref_model imm_gen_ref_model.cpp
import "DPI-C" function int unsigned dpi_imm_gen_compute(
                                //(SV type)           (DPI-C type)    (C++ type)
    input int unsigned inst     //word_t(32 bits)  -> int unsigned  -> uint32_t
);

class imm_gen_ref_model extends uvm_object;
  `uvm_object_utils(imm_gen_ref_model);

  function new(string name = "imm_gen_ref_model");
    super.new(name);
  endfunction

  function word_t compute(word_t inst);
    return dpi_imm_gen_compute(inst);
  endfunction
endclass

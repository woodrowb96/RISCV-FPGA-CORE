//Import the c++ ref_model alu_ref_model.cpp
import "DPI-C" function void dpi_alu_compute(
                                  //(SV type)           (DPI-C type)    (C++ type)
    input  byte unsigned alu_op,  //alu_op_t(4 bits) -> byte unsigned -> uint8_t
    input  int unsigned  in_a,    //word_t(32 bits)  -> int unsigned  -> uint32_t
    input  int unsigned  in_b,    //word_t(32 bits)  -> int unsigned  -> uint32_t
    output int unsigned  result,  //word_t(32 bits)  <- int unsigned  <- uint32_t
    output byte unsigned zero     //logic (1 bit)    <- byte unsigned <- uint8_t
);

typedef struct {
  word_t result;
  logic zero;
} alu_out_t;

class alu_ref_model extends uvm_object;
  `uvm_object_utils(alu_ref_model);

  function new(string name = "alu_ref_model");
    super.new(name);
  endfunction

  function alu_out_t compute(alu_op_t alu_op, word_t in_a, word_t in_b);
    int unsigned result = 32'h00BADBAD;
    byte unsigned zero  = 1'b0;

    dpi_alu_compute(alu_op, in_a, in_b, result, zero);

    return '{result, zero};
  endfunction
endclass

package imm_gen_seq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;

  import imm_gen_agent_pkg::*;

  `include "imm_gen_base_seq.sv"
  `include "imm_gen_rand_seq.sv"
endpackage

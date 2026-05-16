package reg_file_seq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
  import rv32i_verify_pkg::*;

  import reg_file_agent_pkg::*;

  `include "reg_file_base_seq.sv"
  `include "reg_file_rand_seq.sv"
endpackage

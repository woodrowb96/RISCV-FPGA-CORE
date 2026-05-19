package if_stage_seq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import rv32i_control_pkg::*;
  import rv32i_verify_pkg::*;

  import if_stage_agent_pkg::*;

  `include "if_stage_base_seq.sv"
  `include "if_stage_rand_seq.sv"
endpackage

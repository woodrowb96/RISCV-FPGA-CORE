package if_stage_tests_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;

  import if_stage_env_pkg::*;
  import if_stage_agent_pkg::*;
  import if_stage_seq_pkg::*;

  `include "if_stage_base_test.sv"
  `include "if_stage_rand_test.sv"
endpackage

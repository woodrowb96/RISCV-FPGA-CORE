package id_stage_tests_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;

  import id_stage_env_pkg::*;
  import id_stage_agent_pkg::*;
  import id_stage_seq_pkg::*;

  `include "id_stage_base_test.sv"
  `include "id_stage_rand_test.sv"
endpackage

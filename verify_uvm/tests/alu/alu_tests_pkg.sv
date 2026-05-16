package alu_tests_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;

  import alu_env_pkg::*;
  import alu_agent_pkg::*;
  import alu_seq_pkg::*;

  `include "alu_base_test.sv"
  `include "alu_rand_test.sv"
  `include "alu_add_corner_walk_test.sv"
  `include "alu_sub_corner_walk_test.sv"
endpackage

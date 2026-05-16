package data_mem_tests_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;

  import data_mem_env_pkg::*;
  import data_mem_agent_pkg::*;
  import data_mem_seq_pkg::*;

  `include "data_mem_base_test.sv"
  `include "data_mem_rand_test.sv"
endpackage

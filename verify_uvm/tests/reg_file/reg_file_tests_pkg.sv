package reg_file_tests_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;

  import reg_file_env_pkg::*;
  import reg_file_agent_pkg::*;
  import reg_file_seq_pkg::*;

  `include "reg_file_base_test.sv"
  `include "reg_file_rand_test.sv"
endpackage

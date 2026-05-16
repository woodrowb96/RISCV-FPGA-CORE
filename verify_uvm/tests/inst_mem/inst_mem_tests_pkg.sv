package inst_mem_tests_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;

  import inst_mem_env_pkg::*;
  import inst_mem_agent_pkg::*;
  import inst_mem_seq_pkg::*;

  `include "inst_mem_base_test.sv"
  `include "inst_mem_default_test.sv"
  `include "inst_mem_misaligned_test.sv"
  `include "inst_mem_oob_test.sv"
endpackage

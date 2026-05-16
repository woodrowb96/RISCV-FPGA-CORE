package lut_ram_tests_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_verify_pkg::*;

  import lut_ram_env_pkg::*;
  import lut_ram_agent_pkg::*;
  import lut_ram_seq_pkg::*;

  `include "lut_ram_base_test.sv"
  `include "lut_ram_rand_test.sv"
endpackage

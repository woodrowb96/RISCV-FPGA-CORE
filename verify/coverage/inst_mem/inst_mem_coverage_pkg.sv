package inst_mem_coverage_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import rv32i_verify_pkg::*;

  import inst_mem_agent_pkg::*;

  `include "inst_mem_coverage.sv"
  `include "inst_mem_coverage_subscriber.sv"
endpackage

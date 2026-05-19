package if_stage_coverage_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import rv32i_verify_pkg::*;

  import if_stage_agent_pkg::*;

  `include "if_stage_coverage.sv"
  `include "if_stage_coverage_subscriber.sv"
endpackage

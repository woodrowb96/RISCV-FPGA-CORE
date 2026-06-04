package id_stage_coverage_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import rv32i_verify_pkg::*;

  import id_stage_agent_pkg::*;

  `include "id_stage_coverage.sv"
  `include "id_stage_coverage_subscriber.sv"
endpackage

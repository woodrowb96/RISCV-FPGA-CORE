package lut_ram_coverage_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_verify_pkg::*;

  import lut_ram_agent_pkg::*;

  `include "lut_ram_coverage.sv"
  `include "lut_ram_coverage_subscriber.sv"
endpackage

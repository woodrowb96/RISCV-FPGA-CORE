package lut_ram_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_verify_pkg::*;

  `include "lut_ram_seq_item.sv"
  `include "lut_ram_driver.sv"
  `include "lut_ram_monitor.sv"
  `include "lut_ram_agent.sv"
endpackage

package inst_mem_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import rv32i_verify_pkg::*;

  `include "inst_mem_seq_item.sv"
  `include "inst_mem_driver.sv"
  `include "inst_mem_monitor.sv"
  `include "inst_mem_agent.sv"
endpackage

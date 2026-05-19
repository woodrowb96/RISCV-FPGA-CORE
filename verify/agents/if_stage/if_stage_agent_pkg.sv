package if_stage_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import rv32i_verify_pkg::*;

  `include "if_stage_seq_item.sv"
  `include "if_stage_driver.sv"
  `include "if_stage_monitor.sv"
  `include "if_stage_agent.sv"
endpackage

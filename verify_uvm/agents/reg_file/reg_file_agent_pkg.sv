package reg_file_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
  import rv32i_verify_pkg::*;

  `include "reg_file_seq_item.sv"
  `include "reg_file_driver.sv"
  `include "reg_file_monitor.sv"
  `include "reg_file_agent.sv"
endpackage

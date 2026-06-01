package id_stage_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
  import rv32i_config_pkg::*;
  import rv32i_verify_pkg::*;
  import riscv_inst_pkg::*;

  `include "id_stage_seq_item.sv"
  `include "id_stage_driver.sv"
  `include "id_stage_monitor.sv"
  `include "id_stage_agent.sv"
endpackage

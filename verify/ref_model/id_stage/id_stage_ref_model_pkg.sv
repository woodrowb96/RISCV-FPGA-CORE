package id_stage_ref_model_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import rv32i_defs_pkg::*;
  import rv32i_config_pkg::*;
  import rv32i_control_pkg::*;
  import rv32i_verify_pkg::*;

  import id_stage_agent_pkg::*;
  import reg_file_ref_model_pkg::*;
  import imm_gen_ref_model_pkg::*;

  `include "id_stage_ref_model.sv"
endpackage

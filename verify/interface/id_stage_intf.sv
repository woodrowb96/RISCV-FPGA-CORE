interface id_stage_intf
  import rv32i_defs_pkg::*;
(
  input logic clk
);
  logic  rd_wr_en_wb; //DUT control
  word_t pc_if;       //DUT input
  word_t inst_if;
  word_t rd_data_wb;
  word_t pc_id;       //DUT output
  word_t rs1_data_id;
  word_t rs2_data_id;
  word_t imm_id;

  clocking cb_drv @(posedge clk);
    default output #1;
    output rd_wr_en_wb, pc_if, inst_if, rd_data_wb;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #1step;
    input rd_wr_en_wb, pc_if, inst_if, rd_data_wb,
          pc_id, rs1_data_id, rs2_data_id, imm_id;
  endclocking
endinterface

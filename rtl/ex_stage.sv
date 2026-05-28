module ex_stage
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
(
  //control
  input alu_op_t                  alu_op_id,
  input alu_src_sel_2_t           alu_src_sel_2_id,
  input branch_type_t             branch_type_id,
  input branch_target_src_sel_t   branch_target_src_sel_id,

  //input
  input word_t pc_id,
  input word_t imm_id,
  input word_t rs1_data_id,
  input word_t rs2_data_id,

  //output
  output logic  branch_taken_ex,
  output word_t branch_target_ex,
  output word_t alu_result_ex,
  output word_t rs2_data_ex
);
  //alu source selection
  word_t alu_src_2;

  //signals used to calc the branch_taken
  logic eq;  //equal
  logic lt;  //less than signed
  logic ltu; //less than unsigned

  /************** PASS THROUGHS **************/
  assign rs2_data_ex = rs2_data_id;

  /********* ALU SOURCE_2 SELECT ************/
  always_comb begin
    unique case(alu_src_sel_2_id)
      RS2: begin
        alu_src_2 = rs2_data_id;
      end
      IMM: begin
        alu_src_2 = imm_id;
      end
      default: begin
        alu_src_2 = 'x;
      end
    endcase
  end

  /***************** ALU *******************/
  alu u_alu (
    .alu_op (alu_op_id),
    .in_a   (rs1_data_id),
    .in_b   (alu_src_2),
    .result (alu_result_ex)
  );

  /************* BRANCH_TARGET CALC **************/
  // - add RS1 to the imm for JALR
  // - add PC to the imm for all other branch types
  /***********************************************/
  always_comb begin
    unique case(branch_target_src_sel_id)
      PC: begin
        branch_target_ex = imm_id + pc_id; //imm_id has already been shifted left in the imm_gen
      end
      RS1: begin
        branch_target_ex = imm_id + rs1_data_id;
      end
      default: begin
        branch_target_ex = 'x;
      end
    endcase
  end

  /************** BRANCH_TAKEN CALC ****************/
  always_comb begin
    eq  = rs1_data_id == rs2_data_id;
    lt  = $signed(rs1_data_id) <  $signed(rs2_data_id);
    ltu = rs1_data_id <  rs2_data_id;

    unique case(branch_type_id)
      BEQ: begin
        branch_taken_ex = eq;
      end
      BNE: begin
        branch_taken_ex = !eq;
      end
      BLT: begin
        branch_taken_ex = lt;
      end
      BGE: begin
        branch_taken_ex = !lt;
      end
      BLTU: begin
        branch_taken_ex = ltu;
      end
      BGEU: begin
        branch_taken_ex = !ltu;
      end
      JUMP: begin
        branch_taken_ex = 1'b1;
      end
      NONE: begin
        branch_taken_ex = 1'b0;
      end
      default: begin
        branch_taken_ex = 'x;
      end
    endcase
  end
endmodule

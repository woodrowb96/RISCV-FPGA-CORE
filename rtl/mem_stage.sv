module mem_stage
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
(
  input logic clk,

  //control
  input byte_sel_t  store_byte_sel_ex,
  input load_type_t load_type_ex,

  //input
  input word_t alu_result_ex,
  input word_t rs2_data_ex,

  //output
  output word_t alu_result_mem,
  output word_t load_data_mem
);
  word_t raw_load_data;

  /************ PASS THROUGHS ***********/
  assign alu_result_mem = alu_result_ex;

  /************** DATA MEMORY************/
  data_mem u_data_mem (
    .clk(clk),
    .store_byte_sel(store_byte_sel_ex),
    .addr(alu_result_ex),
    .store_data(rs2_data_ex),
    .load_data(raw_load_data)
  );

  /*********** CALC LOAD DATA ***************/
  always_comb begin
    unique case(load_type_ex)
      LOAD_B: begin
        load_data_mem = {{24{raw_load_data[7]}}, raw_load_data[7:0]};
      end
      LOAD_H: begin
        load_data_mem = {{16{raw_load_data[15]}}, raw_load_data[15:0]};
      end
      LOAD_W: begin
        load_data_mem = raw_load_data;
      end
      LOAD_BU: begin
        load_data_mem = {24'b0, raw_load_data[7:0]};
      end
      LOAD_HU: begin
        load_data_mem = {16'b0, raw_load_data[15:0]};
      end
      default: begin
        load_data_mem = 'x;
      end
    endcase
  end
endmodule

/*
  ALU module for riscv rv32i implementation.

Control:
  alu_op  : 4'b alu operation

Input:
  in_a  :  32'b input a
  in_b  :  32'b input b

Output:
  result  : 32'b result of operation
            - Note: result will output 0 if alu_op is an invalid operation

Output flags:
  zero: 1'b zero flag, set when result == 0
*/
import rv32i_defs_pkg::*;
import rv32i_control_pkg::*;

module alu(
  //control
  input alu_op_t alu_op,

  //input
  input word_t in_a,
  input word_t in_b,

  //output
  output word_t result,

  //output flags
  output logic zero
);

  assign zero = (result == '0);

  always_comb begin
    unique case(alu_op)
      ALU_AND: begin
        result = in_a & in_b;
      end
      ALU_OR: begin
        result = in_a | in_b;
      end
      ALU_XOR: begin
        result = in_a ^ in_b;
      end
      ALU_ADD: begin
        result = in_a + in_b;
      end
      ALU_SUB: begin
        result = in_a - in_b;
      end
      ALU_SLT: begin
        result = $signed(in_a) < $signed(in_b);
      end
      ALU_SLTU: begin
        result = in_a < in_b;
      end
      ALU_SLL: begin
        //per rv32i spec we only shift by the amount in the lower 5 bits of in_b
        result = in_a << in_b[4:0];
      end
      ALU_SRL: begin
        result = in_a >> in_b[4:0];
      end
      ALU_SRA: begin
        result = $signed(in_a) >>> in_b[4:0];
      end
      default: begin
        result = '0;
      end
    endcase
  end

endmodule

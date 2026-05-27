/*
  The SVA concurrent property versions of all assertions are commented out at the
  bottom of this file. I decided to leave them in so anyone can see what I
  intended to do if the tool worked. They are replaced with immediate assertions
  wrapped in always @(posedge clk) blocks above them.

  VIVADO BUG:
    xsim crashes with a FATAL_ERROR ("Vivado Simulator kernel has discovered
    an exceptional condition from which it cannot recover") when evaluating
    concurrent SVA properties that use hierarchical references
    (e.g. data_mem.byte_0_addr) passed as property arguments.

*/

module data_mem_assert
  import rv32i_defs_pkg::*;
  import rv32i_control_pkg::*;
(
  input logic clk,
  input byte_sel_t store_byte_sel,
  input word_t addr,
  input word_t store_data,
  input word_t load_data
);
  typedef logic [$clog2(DATA_MEM_DEPTH)-1:0] lut_addr_t;

  /*=============================================================================*/
  /*------------------------ LUT_RAM ASSERTIONS ---------------------------------*/
  /*=============================================================================*/

  //lut ram assertions will provide the write and read assertions directly touching memory
  bind data_mem.u_byte_0 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);
  bind data_mem.u_byte_1 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);
  bind data_mem.u_byte_2 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);
  bind data_mem.u_byte_3 lut_ram_assert #(.LUT_WIDTH(LUT_WIDTH), .LUT_DEPTH(LUT_DEPTH)) assert_inst(.*);

  /*=============================================================================*/
  /*------------------------ ADDRESS CALC CHECK ---------------------------------*/
  /*=============================================================================*/

  //We need to look at the offset and make sure each lut_ram's address is
  //getting calculated correctly
  always @(posedge clk) begin
    #0
    unique case(addr[1:0])

      /******* offset 0 ******/
      //We are word aligned
      // - Each lut_ram pulls from the same line in memory
      2'b00: begin
        assert(data_mem.byte_3_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_3: offset=00 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_3_addr);

        assert(data_mem.byte_2_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_2: offset=00 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_2_addr);

        assert(data_mem.byte_1_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_1: offset=00 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_1_addr);

        assert(data_mem.byte_0_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_0: offset=00 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_0_addr);
      end

      /******* offset 1 ******/
      //We are shifted over a byte
      // - byte_0 gets bumped to the next line in memory
      2'b01: begin
        assert(data_mem.byte_3_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_3: offset=01 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_3_addr);

        assert(data_mem.byte_2_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_2: offset=01 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_2_addr);

        assert(data_mem.byte_1_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_1: offset=01 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_1_addr);

        assert(data_mem.byte_0_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_0: offset=01 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr);
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - byte_1 gets bumped to the next line in memory
      2'b10: begin
        assert(data_mem.byte_3_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_3: offset=10 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_3_addr);

        assert(data_mem.byte_2_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_2: offset=10 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_2_addr);

        assert(data_mem.byte_1_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_1: offset=10 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_1_addr);

        assert(data_mem.byte_0_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_0: offset=10 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr);
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - byte_2 gets bumped to the next line in memory
      2'b11: begin
        assert(data_mem.byte_3_addr === lut_addr_t'(addr[XLEN-1:2])) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_3: offset=11 expected=%0h, actual=%0h",
                  addr[XLEN-1:2], data_mem.byte_3_addr);

        assert(data_mem.byte_2_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_2: offset=11 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_2_addr);

        assert(data_mem.byte_1_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_1: offset=11 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_1_addr);

        assert(data_mem.byte_0_addr === lut_addr_t'(addr[XLEN-1:2] + 'd1)) else
          $error("[DATA_MEM_ASSERT] addr calc failed byte_0: offset=11 expected=%0h, actual=%0h",
                  lut_addr_t'(addr[XLEN-1:2] + 'd1), data_mem.byte_0_addr);
      end

      default: begin end
    endcase
  end

  /*=============================================================================*/
  /*------------------------ STORE_BYTE_SEL ROUTE CHECK ---------------------------------*/
  /*=============================================================================*/
  byte_sel_t lut_ram_wr_en_exp;

  //look at the byte offset and make sure store_byte_sel is routed correctly
  always @(posedge clk) begin
    #0
    unique case(addr[1:0])

      /******* offset 0 ******/
      //We are word aligned
      // - store_byte_sel routed to: {u_byte_3, u_byte_2, u_byte_1, u_byte_0}
      2'b00: begin
        lut_ram_wr_en_exp = {store_byte_sel[3], store_byte_sel[2], store_byte_sel[1], store_byte_sel[0]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] store_byte_sel route failed: offset=00 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end

      /******* offset 1 ******/
      //We are shifted over a byte
      // - store_byte_sel routed to: {u_byte_2, u_byte_1, u_byte_0, u_byte_3}
      2'b01: begin
        lut_ram_wr_en_exp = {store_byte_sel[2], store_byte_sel[1], store_byte_sel[0], store_byte_sel[3]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] store_byte_sel route failed: offset=01 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - store_byte_sel routed to: {u_byte_1, u_byte_0, u_byte_3, u_byte_2}
      2'b10: begin
        lut_ram_wr_en_exp = {store_byte_sel[1], store_byte_sel[0], store_byte_sel[3], store_byte_sel[2]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] store_byte_sel route failed: offset=10 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end

      /******* offset 3 ******/
      //We are shifted over three bytes
      // - store_byte_sel routed to: {u_byte_0, u_byte_3, u_byte_2, u_byte_1}
      2'b11: begin
        lut_ram_wr_en_exp = {store_byte_sel[0], store_byte_sel[3], store_byte_sel[2], store_byte_sel[1]};

        assert(data_mem.lut_ram_wr_en === lut_ram_wr_en_exp) else
          $error("[DATA_MEM_ASSERT] store_byte_sel route failed: offset=11 addr=%0h, expected=%0h, actual=%0h",
                  addr, lut_ram_wr_en_exp, data_mem.lut_ram_wr_en);
      end

      default: begin end
    endcase
  end

  /*=============================================================================*/
  /*------------------------ STORE_DATA ROUTE CHECK --------------------------------*/
  /*=============================================================================*/
  word_t store_data_actual;

  //make sure we are routing the right store_data based on byte offset
  always @(posedge clk) begin
    #0
    unique case(addr[1:0])

      /******* offset 0 ******/
      //We are word aligned
      // - store_data routed to: {u_byte_3, u_byte_2, u_byte_1, u_byte_0}
      2'b00: begin
        store_data_actual = { {data_mem.u_byte_3.wr_data,
                            data_mem.u_byte_2.wr_data,
                            data_mem.u_byte_1.wr_data,
                            data_mem.u_byte_0.wr_data} };

        assert(store_data === store_data_actual) else
          $error("[DATA_MEM_ASSERT] store_data route failed: offset=00 addr=%0h, expected=%0h, actual=%0h",
                  addr, store_data, store_data_actual);
      end

      /******* offset 1 ******/
      //We are shifted over a byte
      // - store_data routed to: {u_byte_0, u_byte_3, u_byte_2, u_byte_1}
      2'b01: begin
        store_data_actual = { {data_mem.u_byte_0.wr_data,
                            data_mem.u_byte_3.wr_data,
                            data_mem.u_byte_2.wr_data,
                            data_mem.u_byte_1.wr_data} };

        assert(store_data === store_data_actual) else
          $error("[DATA_MEM_ASSERT] store_data route failed: offset=01 addr=%0h, expected=%0h, actual=%0h",
                  addr, store_data, store_data_actual);
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - store_data routed to: {u_byte_1, u_byte_0, u_byte_3, u_byte_2}
      2'b10: begin
        store_data_actual = { {data_mem.u_byte_1.wr_data,
                            data_mem.u_byte_0.wr_data,
                            data_mem.u_byte_3.wr_data,
                            data_mem.u_byte_2.wr_data} };

        assert(store_data === store_data_actual) else
          $error("[DATA_MEM_ASSERT] store_data route failed: offset=10 addr=%0h, expected=%0h, actual=%0h",
                  addr, store_data, store_data_actual);
      end

      /******* offset 3 ******/
      //We are shifted over three bytes
      // - store_data routed to: {u_byte_2, u_byte_1, u_byte_0, u_byte_3}
      2'b11: begin
        store_data_actual = { {data_mem.u_byte_2.wr_data,
                            data_mem.u_byte_1.wr_data,
                            data_mem.u_byte_0.wr_data,
                            data_mem.u_byte_3.wr_data} };

        assert(store_data === store_data_actual) else
          $error("[DATA_MEM_ASSERT] store_data route failed: offset=11 addr=%0h, expected=%0h, actual=%0h",
                  addr, store_data, store_data_actual);
      end

      default: begin end
    endcase
  end

  /*=============================================================================*/
  /*------------------------ LOAD_DATA ROUTE CHECK --------------------------------*/
  /*=============================================================================*/
  word_t load_data_exp;

  //Look at the byte offset, construct the expected word directly from the
  //byte lane memories, and compare it to the actual load_data
  always @(posedge clk) begin
    #0
    unique case(addr[1:0])

      /******* offset 0 ******/
      //We are word aligned
      // - load_data formed from: {u_byte_3, u_byte_2, u_byte_1, u_byte_0}
      2'b00: begin
        load_data_exp = {data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(load_data === load_data_exp) else
          $error("[DATA_MEM_ASSERT] load_data route failed: offset=00 addr=%0h, expected=%0h, actual=%0h",
                  addr, load_data_exp, load_data);
      end

      /******* offset 1 ******/
      //We are shifted over a byte
      // - load_data formed from: {u_byte_0(+1), u_byte_3, u_byte_2, u_byte_1}
      2'b01: begin
        load_data_exp = {data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(load_data === load_data_exp) else
          $error("[DATA_MEM_ASSERT] load_data route failed: offset=01 addr=%0h, expected=%0h, actual=%0h",
                  addr, load_data_exp, load_data);
      end

      /******* offset 2 ******/
      //We are shifted over two bytes
      // - load_data formed from: {u_byte_1(+1), u_byte_0(+1), u_byte_3, u_byte_2}
      2'b10: begin
        load_data_exp = {data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])],
                      data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(load_data === load_data_exp) else
          $error("[DATA_MEM_ASSERT] load_data route failed: offset=10 addr=%0h, expected=%0h, actual=%0h",
                  addr, load_data_exp, load_data);
      end

      /******* offset 3 ******/
      //We are shifted over three bytes
      // - load_data formed from: {u_byte_2(+1), u_byte_1(+1), u_byte_0(+1), u_byte_3}
      2'b11: begin
        load_data_exp = {data_mem.u_byte_2.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_1.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_0.mem[lut_addr_t'(addr[XLEN-1:2] + 'd1)],
                      data_mem.u_byte_3.mem[lut_addr_t'(addr[XLEN-1:2])]};

        assert(load_data === load_data_exp) else
          $error("[DATA_MEM_ASSERT] load_data route failed: offset=11 addr=%0h, expected=%0h, actual=%0h",
                  addr, load_data_exp, load_data);
      end

      default: begin end
    endcase
  end

endmodule

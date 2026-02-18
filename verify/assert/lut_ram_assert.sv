module lut_ram_assert(
  lut_ram_intf.monitor intf
);

/********  WRITE CHECK *************/
  //We want to make sure writes are actually written into mem on the next clk cycle
  property write_check_prop;
    @(posedge intf.clk)
    (intf.wr_en) |=> (lut_ram.ram[$past(intf.wr_addr)] == $past(intf.wr_data));
  endproperty

  write_check_assert:
    assert property(write_check_prop) else
      $error("[LUT_RAM_ASSERT] (write_check_assert): wr_data not written into wr_addr");

/********  READ CHECK *************/
  //Make sure we read the actual data stored at the rd_addr
  always @(posedge intf.clk) begin
    #0
    assert(intf.rd_data === lut_ram.ram[intf.rd_addr]) else
      $error("[LUT_RAM_ASSERT] (read_check_assert): rd_data not reading correct rd_data from mem\n",
              "rd_addr: %0d, mem[rd_addr]: %0h, rd_data: %0h",
              intf.rd_addr, lut_ram.ram[intf.rd_addr], intf.rd_data);
  end

endmodule

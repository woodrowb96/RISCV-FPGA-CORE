package rv32i_verify_pkg;
  localparam CLK_PERIOD = 10;
  localparam DEFAULT_RESET_CYCLES = 5;

  /********************** DUT LATENCIES ************************/
  //  - How long it takes the last seq_item to flow through the 
  //    DUT and into the scoreboard
  /*************************************************************/
  localparam ALU_LATENCY = 0; //alu is purely combinatorial so it takes 0 clk cycles
endpackage

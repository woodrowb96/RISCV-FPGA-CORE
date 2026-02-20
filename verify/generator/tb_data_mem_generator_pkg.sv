package tb_data_mem_generator_pkg;
  import riscv_32i_defs_pkg::*;
  import riscv_32i_config_pkg::*;
  import tb_data_mem_transaction_pkg::*;

  class tb_data_mem_generator;
    function data_mem_trans gen_trans();
      data_mem_trans trans = new();

      assert(trans.randomize()) else
        $fatal(1, "TB_DATA_MEM_GENERATOR: gen_trans() randomization failed");

      return trans;
    endfunction
  endclass
endpackage

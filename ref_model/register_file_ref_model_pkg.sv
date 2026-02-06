package register_file_ref_model_pkg;
  //reference reg file to hold expected values
  class reg_file_ref_model;
    logic [31:0] expected [0:31];

    //write expected values into the expected array
    function void write(logic [4:0] index, logic [31:0] data);
    //protect against x0 overwritted
    //check with an assertion that the expected x0 still equals 0
      if(index != 0) begin
        expected[index] = data;
      end
      exp_x0_wr_check: assert(expected[0] === 0)
        else $fatal(1, "REF_REG_FILE::write(): expected x0 != 0");
    endfunction

    //Read expected values out of expected array
    function logic[31:0] read(logic [4:0] index);
    //always return 0 from expected x0
      if(index == 0) begin
        return 0;
      end
      return expected[index];
    endfunction

    function new();
      //initialize x0 to 0
      expected[0] = 0;
    endfunction
  endclass
endpackage

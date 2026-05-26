class if_stage_driver extends uvm_driver #(if_stage_seq_item);
  `uvm_component_utils(if_stage_driver)

  virtual if_stage_intf if_vif;
  virtual reset_intf    rst_vif;

  function new(string name = "if_stage_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual if_stage_intf)::get(this, "", "if_stage_vif", if_vif)) begin
      `uvm_fatal("DRV", "Could not get if_stage vif")
    end
    if(!uvm_config_db#(virtual reset_intf)::get(this, "", "reset_vif", rst_vif)) begin
      `uvm_fatal("DRV", "Could not get reset vif")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    if_stage_seq_item item;
    super.run_phase(phase);

    if_vif.branch_taken_ex        = 1'b0;
    if_vif.branch_target_ex = 'd5;
    @(if_vif.cb_drv);  //clk initial values onto the DUT

    forever begin
      //Wait for the reset to get deasserted
      wait(rst_vif.reset_n === 1'b1);

      //Concurently
      //  - drive the items into the interface
      //  - wait for the next reset to get asserted
      fork
        begin : drive_loop
          forever begin
            seq_item_port.get_next_item(item);
            @(if_vif.cb_drv);
            if_vif.cb_drv.branch_taken_ex        <= item.branch_taken_ex;
            if_vif.cb_drv.branch_target_ex <= item.branch_target_ex;
            seq_item_port.item_done();
          end
        end
        begin : reset_loop
          @(negedge rst_vif.reset_n);
        end
      join_any
      disable fork;

      //Drive the interface during the reset
      if_vif.cb_drv.branch_taken_ex        <= 1'b0;
      if_vif.cb_drv.branch_target_ex <= 'd5;
    end
  endtask
endclass


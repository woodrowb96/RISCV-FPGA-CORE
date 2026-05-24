class if_stage_monitor extends uvm_monitor;
  `uvm_component_utils(if_stage_monitor)

  virtual if_stage_intf if_vif;
  virtual reset_intf    rst_vif;
  uvm_analysis_port #(if_stage_seq_item) observed_ap;

  function new(string name = "if_stage_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual if_stage_intf)::get(this, "", "if_stage_vif", if_vif)) begin
      `uvm_fatal("MON", "could not get if_stage vif");
    end

    if(!uvm_config_db#(virtual reset_intf)::get(this, "", "reset_vif", rst_vif)) begin
      `uvm_fatal("MON", "could not get reset vif");
    end

    observed_ap = new("observed_ap", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    if_stage_seq_item item;
    super.run_phase(phase);

    @(if_vif.cb_mon); //wait for the initial drives to get cloked in

    forever begin
      wait(rst_vif.reset_n === 1'b1);

      //Concurently
      //  - monitor the items on the interface
      //  - monitor the reset, exit fork when its asserted
      fork
        begin : sample_loop
          forever begin
            @(if_vif.cb_mon);
            item = if_stage_seq_item::type_id::create("item");
            item.pc_if            = if_vif.cb_mon.pc_if;
            item.inst_if          = if_vif.cb_mon.inst_if;
            item.branch_ex        = if_vif.cb_mon.branch_ex;
            item.branch_target_ex = if_vif.cb_mon.branch_target_ex;
            observed_ap.write(item);
            `uvm_info("MON", $sformatf("Saw item %s", item.convert2string()), UVM_HIGH)
          end
        end
        begin : reset_loop
          @(negedge rst_vif.reset_n);
        end
      join_any
      disable fork;
    end
  endtask
endclass

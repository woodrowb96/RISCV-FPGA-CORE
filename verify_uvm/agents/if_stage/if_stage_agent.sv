typedef uvm_sequencer #(if_stage_seq_item) if_stage_sequencer_t;

class if_stage_agent extends uvm_agent;
  `uvm_component_utils(if_stage_agent)

  if_stage_driver      drv;
  if_stage_monitor     mon;
  if_stage_sequencer_t seqr;

  function new(string name = "if_stage_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = if_stage_monitor::type_id::create("mon", this);

    if(get_is_active() == UVM_ACTIVE) begin
      seqr = if_stage_sequencer_t::type_id::create("seqr", this);
      drv = if_stage_driver::type_id::create("drv", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass

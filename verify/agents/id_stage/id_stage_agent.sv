typedef uvm_sequencer #(id_stage_seq_item) id_stage_sequencer_t;

class id_stage_agent extends uvm_agent;
  `uvm_component_utils(id_stage_agent)

  id_stage_driver      drv;
  id_stage_monitor     mon;
  id_stage_sequencer_t seqr;

  function new(string name = "id_stage_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = id_stage_monitor::type_id::create("mon", this);

    if(get_is_active() == UVM_ACTIVE) begin
      seqr = id_stage_sequencer_t::type_id::create("seqr", this);
      drv  = id_stage_driver::type_id::create("drv", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass

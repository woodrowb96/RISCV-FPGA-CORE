typedef uvm_sequencer #(inst_mem_seq_item) inst_mem_sequencer_t;

class inst_mem_agent extends uvm_agent;
  `uvm_component_utils(inst_mem_agent)

  inst_mem_driver      drv;
  inst_mem_monitor     mon;
  inst_mem_sequencer_t seqr;

  function new(string name = "inst_mem_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = inst_mem_monitor::type_id::create("mon", this);

    if(get_is_active() == UVM_ACTIVE) begin
      seqr = inst_mem_sequencer_t::type_id::create("seqr", this);
      drv = inst_mem_driver::type_id::create("drv", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass

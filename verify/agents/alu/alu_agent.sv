typedef uvm_sequencer #(alu_seq_item) alu_sequencer_t;

class alu_agent extends uvm_agent;
  `uvm_component_utils(alu_agent)

  alu_driver      drv;
  alu_monitor     mon;
  alu_sequencer_t seqr;

  function new(string name = "alu_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = alu_monitor::type_id::create("mon", this);

    if(get_is_active() == UVM_ACTIVE) begin
      seqr = alu_sequencer_t::type_id::create("seqr", this);
      drv = alu_driver::type_id::create("drv", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass

typedef uvm_sequencer #(lut_ram_seq_item) lut_ram_sequencer_t;

class lut_ram_agent extends uvm_agent;
  `uvm_component_utils(lut_ram_agent)

  lut_ram_driver      drv;
  lut_ram_monitor     mon;
  lut_ram_sequencer_t seqr;

  function new(string name = "lut_ram_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = lut_ram_monitor::type_id::create("mon", this);

    if(get_is_active() == UVM_ACTIVE) begin
      seqr = lut_ram_sequencer_t::type_id::create("seqr", this);
      drv = lut_ram_driver::type_id::create("drv", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass

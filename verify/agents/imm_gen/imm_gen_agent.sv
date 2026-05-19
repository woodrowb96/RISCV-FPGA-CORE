typedef uvm_sequencer #(imm_gen_seq_item) imm_gen_sequencer_t;

class imm_gen_agent extends uvm_agent;
  `uvm_component_utils(imm_gen_agent)

  imm_gen_driver      drv;
  imm_gen_monitor     mon;
  imm_gen_sequencer_t seqr;

  function new(string name = "imm_gen_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = imm_gen_monitor::type_id::create("mon", this);

    if(get_is_active() == UVM_ACTIVE) begin
      seqr = imm_gen_sequencer_t::type_id::create("seqr", this);
      drv = imm_gen_driver::type_id::create("drv", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass

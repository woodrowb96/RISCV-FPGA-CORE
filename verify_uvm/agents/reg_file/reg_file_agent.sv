typedef uvm_sequencer #(reg_file_seq_item) reg_file_sequencer_t;

class reg_file_agent extends uvm_agent;
  `uvm_component_utils(reg_file_agent)

  reg_file_driver      drv;
  reg_file_monitor     mon;
  reg_file_sequencer_t seqr;

  function new(string name = "reg_file_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = reg_file_monitor::type_id::create("mon", this);

    if(get_is_active() == UVM_ACTIVE) begin
      seqr = reg_file_sequencer_t::type_id::create("seqr", this);
      drv = reg_file_driver::type_id::create("drv", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass

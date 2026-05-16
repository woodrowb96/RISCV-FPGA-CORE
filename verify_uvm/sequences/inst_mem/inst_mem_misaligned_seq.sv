/*
  Misaligned addresses only (non-zero byte offset).

  Randomize first, then override the bottom 2 bits to a non-zero value.
  Using override instead of an inline `inst_addr[1:0] != 2'b00` constraint
  to sidestep the Vivado inline-bit-slice-constraint seg fault.
*/
class inst_mem_misaligned_seq extends inst_mem_base_seq;
  `uvm_object_utils(inst_mem_misaligned_seq);

  function new(string name = "inst_mem_misaligned_seq");
    super.new(name);
  endfunction

  virtual task body();
    inst_mem_seq_item item;

    for(int i = 0; i < seq_length; i++) begin
      item = inst_mem_seq_item::type_id::create("item");

      start_item(item);
      if (!item.randomize())
        `uvm_fatal("SEQ", "Failed item.randomize()")

      //override the bottom 2 bits to force a misaligned access
      randcase
        1: item.inst_addr[1:0] = 2'b01;
        1: item.inst_addr[1:0] = 2'b10;
        1: item.inst_addr[1:0] = 2'b11;
      endcase

      `uvm_info("SEQ", $sformatf("Generate new item: %s", item.convert2string()), UVM_HIGH);
      finish_item(item);
    end

    `uvm_info("SEQ", $sformatf("Done generating %0d items", seq_length), UVM_HIGH);
  endtask
endclass

class reset_seq_item extends uvm_sequence_item;
  `uvm_object_utils(reset_seq_item)

  rand bit [7:0] idle_duration;   //how many cycles between each reset assertion
  rand bit [7:0] assert_duration; //how many cycles to hold reset asserted

  constraint default_idle_duration {
    idle_duration inside {[0:20]};
  }

  constraint default_assert_duration {
    assert_duration inside {[2:5]};
  }

  function new(string name = "reset_seq_item");
    super.new(name);
  endfunction
endclass

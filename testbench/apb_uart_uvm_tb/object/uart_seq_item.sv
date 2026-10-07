class uart_seq_item extends uvm_sequence_item;

  rand bit          [7:0] data;
  rand int unsigned       baud;

  constraint baud_c { baud inside {[1200:1000000]}; }
  `uvm_object_utils_begin(uart_seq_item)
     `uvm_field_int(data,UVM_ALL_ON)
     `uvm_field_int(baud,UVM_ALL_ON)
  `uvm_object_utils_end


  function new(string name="uart_seq_item");
    super.new(name);
    baud=9600;
  endfunction

endclass

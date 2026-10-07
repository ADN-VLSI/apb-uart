class apb_seq_item extends uvm_sequence_item;

  rand bit        write;
  rand bit [31:0] addr, data;
  bit      [31:0] rdata;
  bit             error;

  `uvm_object_utils_begin(apb_seq_item)
  `uvm_field_int(write,UVM_ALL_ON)
  `uvm_field_int(addr,UVM_ALL_ON)
  `uvm_field_int(data,UVM_ALL_ON)
  `uvm_field_int(rdata,UVM_ALL_ON)
  `uvm_field_int(error,UVM_ALL_ON)
  `uvm_object_utils_end


  function new(string name="apb_seq_item");
    super.new(name);
    endfunction

endclass

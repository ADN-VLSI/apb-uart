class apb_seq_item extends uvm_sequence_item;

  `uvm_object_utils(apb_seq_item)

  // APB transaction fields
  rand bit [31:0] paddr;
  rand bit        pwrite;
  rand bit [31:0] pwdata;

  // Response fields
  bit [31:0] prdata;
  bit        pslverr;

  // Transaction constraints
  constraint c_addr_aligned {
    paddr[1:0] == 2'b00;
  }

  // Constructor
  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction

endclass
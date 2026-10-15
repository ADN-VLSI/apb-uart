class apb_rsp_item extends uvm_sequence_item;

  `uvm_object_utils(apb_rsp_item)

  // APB response
  bit [31:0] prdata;
  bit        pslverr;
  bit        pready;

  // Constructor
  function new(string name = "apb_rsp_item");
    super.new(name);
  endfunction

endclass

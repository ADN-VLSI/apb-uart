// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_APB_RSP_ITEM_SV__
`define __GUARD_APB_RSP_ITEM_SV__ 0

// Include the base APB sequence item class
`include "object/apb_seq_item.sv"

// APB Response Sequence Item
// This class extends apb_seq_item to include response-specific fields
// for APB transactions, such as read data, error status, and ready signal.
class apb_rsp_item extends apb_seq_item;

  `uvm_object_utils_begin(apb_rsp_item)
    `uvm_field_int(prdata, UVM_ALL_ON)
    `uvm_field_int(pslverr, UVM_ALL_ON)
    `uvm_field_int(pready, UVM_ALL_ON)
  `uvm_object_utils_end

  // Response fields
  bit [31:0] prdata;  // Read data returned from the slave
  bit pslverr;        // Slave error signal (1 if error occurred)
  bit pready;         // Ready signal indicating slave is ready for next transfer

  // Constructor for the APB response sequence item
  function new(string name = "apb_rsp_item");
    super.new(name);
  endfunction : new

endclass

`endif

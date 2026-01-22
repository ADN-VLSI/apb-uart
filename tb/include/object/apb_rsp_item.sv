// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_APB_RSP_ITEM_SV__
`define __GUARD_APB_RSP_ITEM_SV__ 0

// APB Response Sequence Item
// This class extends uvm_sequence_item to include response-specific fields
// for APB transactions, such as read data, error status, and ready signal.
class apb_rsp_item extends uvm_sequence_item;

  bit [31:0] paddr;    // Address of the APB transaction
  bit        pwrite;   // Read/Write indicator (0: Read, 1: Write)
  bit [31:0] pwdata;   // Write data for write transactions
  bit [3:0]  pstrb;    // Byte strobe signals
  bit [31:0] prdata;   // Read data returned from the slave
  bit        pslverr;  // Slave error signal (1 if error occurred)

  `uvm_object_utils_begin(apb_rsp_item)
    `uvm_field_int(paddr, UVM_ALL_ON)
    `uvm_field_int(pwrite, UVM_ALL_ON)
    `uvm_field_int(pwdata, UVM_ALL_ON)
    `uvm_field_int(pstrb, UVM_ALL_ON)
    `uvm_field_int(prdata, UVM_ALL_ON)
    `uvm_field_int(pslverr, UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor for the APB response sequence item
  function new(string name = "apb_rsp_item");
    super.new(name);
  endfunction : new

endclass

`endif

// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_UART_RSP_ITEM_SV__
`define __GUARD_UART_RSP_ITEM_SV__ 0

// Include the base UART sequence item class
`include "object/uart_seq_item.sv"

// UART Response Sequence Item
// This class extends uart_seq_item to include response-specific fields
// for UART transactions, such as direction indicator.
class uart_rsp_item extends uart_seq_item;

  // UVM object utilities for factory registration
  `uvm_object_utils(uart_rsp_item)

  // Response field
  bit direction; // 0 for RX, 1 for TX

  // Constructor for the UART response sequence item
  function new(string name = "uart_rsp_item");
    super.new(name);
  endfunction : new

endclass

`endif

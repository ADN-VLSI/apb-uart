// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_UART_SEQR_SV__
`define __GUARD_UART_SEQR_SV__ 0

// Include the UART sequence item class
`include "object/uart_seq_item.sv"

// UART Sequencer
// This UVM sequencer manages the sequencing of UART transactions
// to the driver.
class uart_seqr extends uvm_sequencer #(uart_seq_item);

  // UVM component utilities for factory registration
  `uvm_component_utils(uart_seqr)

  // Constructor for the UART sequencer
  function new(string name = "uart_seqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass

`endif

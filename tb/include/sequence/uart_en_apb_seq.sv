// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_UART_EN_APB_SEQ_SV__
`define __GUARD_UART_EN_APB_SEQ_SV__ 0

// Include the APB sequence item class
`include "object/apb_seq_item.sv"

// UART Enable APB Sequence
// This sequence performs APB write transactions to enable and configure the UART.
// It flushes the FIFO, sets the clock divider, and enables the UART.
class uart_en_apb_seq extends uvm_sequence #(apb_seq_item);

  // UVM object utilities for factory registration
  `uvm_object_utils(uart_en_apb_seq)

  // Constructor for the UART enable APB sequence
  function new(string name = "uart_en_apb_seq");
    super.new(name);
  endfunction : new

  // Main sequence body: performs UART enable and configuration
  virtual task body();
    `uvm_do_with(req, {req.tx_type == 1; req.addr == 'h00; req.data == 'b110;})   // Flush the UART FIFO
    `uvm_do_with(req, {req.tx_type == 1; req.addr == 'h00; req.data == 'b000;})   // Disable FIFO flush
    `uvm_do_with(req, {req.tx_type == 1; req.addr == 'h04; req.data == 'd16;})    // Set the clock divider to 16
    `uvm_do_with(req, {req.tx_type == 1; req.addr == 'h00; req.data == 'b001;})   // Enable the UART
  endtask : body

endclass

`endif

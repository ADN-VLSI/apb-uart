// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_RANDOM_UART_RX_SEQ_SV__
`define __GUARD_RANDOM_UART_RX_SEQ_SV__ 0

// Include the UART sequence item class
`include "object/uart_seq_item.sv"

// Random UART RX Sequence
// This sequence generates random UART receive (RX) transactions.
// The sequence length can be configured via the "RANDOM_UART_RX_SEQ_LENGTH" parameter.
class random_uart_rx_seq extends uvm_sequence #(uart_seq_item);

  // UVM object utilities for factory registration
  `uvm_object_utils(random_uart_rx_seq)

  // Constructor for the random UART RX sequence
  function new(string name = "random_uart_rx_seq");
    super.new(name);
  endfunction : new

  // Main sequence body: generates RX transactions
  virtual task body();
    int seq_length;
    // Get sequence length from configuration database, default to 1
    if (!uvm_config_db#(int)::get(
            uvm_root::get(), "parameter", "RANDOM_UART_RX_SEQ_LENGTH", seq_length
        ))
      seq_length = 1;
    // Repeat for the specified sequence length
    repeat (seq_length) begin
      // Generate a random UART RX transaction
      `uvm_do(req)
    end
  endtask : body

endclass

`endif

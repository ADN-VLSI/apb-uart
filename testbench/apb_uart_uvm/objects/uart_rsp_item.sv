class uart_rsp_item extends uvm_sequence_item;

  `uvm_object_utils(uart_rsp_item)

  // Received UART data
  bit [7:0] data;

  // Error/status information
  bit parity_error;
  bit framing_error;

  // Constructor
  function new(string name = "uart_rsp_item");
    super.new(name);
  endfunction

endclass
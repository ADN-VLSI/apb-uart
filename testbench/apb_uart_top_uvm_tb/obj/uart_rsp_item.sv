//------------------------------------------------------------------------------
// UART Response Item
// Transaction object describing one UART frame. It is used in two places:
//   - Built by uart_monitor for every frame seen on the DUT TX line
//   - Built by uart_driver for every byte sent into the DUT RX line
// Both go to the scoreboard through analysis ports.
//------------------------------------------------------------------------------
class uart_rsp_item extends uvm_sequence_item;

  //----------------------------------------------------------------------------
  // Fields
  //----------------------------------------------------------------------------
  bit [7:0] data;                           // Decoded / transmitted data byte
  bit       parity_error;                   // 1 = parity check failed
  bit       framing_error;                  // 1 = stop bit was not 1

  //----------------------------------------------------------------------------
  // Factory registration and field automation
  // Enables print(), copy(), compare(), pack() etc. for all listed fields
  //----------------------------------------------------------------------------
  `uvm_object_utils_begin(uart_rsp_item)
    `uvm_field_int(data,          UVM_ALL_ON)
    `uvm_field_int(parity_error,  UVM_ALL_ON)
    `uvm_field_int(framing_error, UVM_ALL_ON)
  `uvm_object_utils_end

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name = "uart_rsp_item");
    super.new(name);                        // Give the item an instance name
  endfunction

endclass
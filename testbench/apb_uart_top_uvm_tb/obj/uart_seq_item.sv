//------------------------------------------------------------------------------
// UART Sequence Item
// Transaction object created by UART sequences and consumed by the UART driver.
// Describes one byte to be serialized onto the DUT's RX line, and the baud
// rate to use for that frame.
//------------------------------------------------------------------------------
class uart_seq_item extends uvm_sequence_item;

  //----------------------------------------------------------------------------
  // Fields (randomizable, set by the sequence)
  //----------------------------------------------------------------------------
  rand bit [7:0]    data;                   // Byte to transmit
  rand int unsigned baud;                   // Baud rate for this frame

  //----------------------------------------------------------------------------
  // Constraints
  //----------------------------------------------------------------------------
  constraint baud_c { baud inside {[1200:1000000]}; }   // Keep baud in a sane range

  //----------------------------------------------------------------------------
  // Factory registration and field automation
  // Enables print(), copy(), compare(), pack() etc. for all listed fields
  //----------------------------------------------------------------------------
  `uvm_object_utils_begin(uart_seq_item)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(baud, UVM_ALL_ON)
  `uvm_object_utils_end

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name = "uart_seq_item");
    super.new(name);                        // Give the item an instance name
    baud = 9600;                            // Default baud when not randomized
  endfunction

endclass
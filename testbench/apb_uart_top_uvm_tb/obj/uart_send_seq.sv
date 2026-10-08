//------------------------------------------------------------------------------
// UART Send Sequence
// Sends one byte into the DUT's UART RX line. The caller sets 'data' (and
// optionally 'baud') before starting the sequence.
//------------------------------------------------------------------------------
class uart_send_seq extends uvm_sequence #(uart_seq_item);

  // Register the class with the UVM factory (sequences are objects, not components)
  `uvm_object_utils(uart_send_seq)

  //----------------------------------------------------------------------------
  // Fields
  //----------------------------------------------------------------------------
  bit [7:0]    data;                        // Byte to send (set by caller)
  int unsigned baud = 9600;                 // Baud rate for this frame (default 9600)

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name = "uart_send_seq");
    super.new(name);                        // Give the sequence an instance name
  endfunction

  //----------------------------------------------------------------------------
  // Body: runs when the sequence is started on a sequencer
  //----------------------------------------------------------------------------
  task body();
    // Create the transaction through the factory
    uart_seq_item req = uart_seq_item::type_id::create("req");

    start_item(req);                        // Request the sequencer; blocks until granted
    req.data = data;                        // Byte to serialize onto the RX line
    req.baud = baud;                        // Baud rate used by the driver's vif.send()
    finish_item(req);                       // Send to driver; returns after item_done()
  endtask

endclass
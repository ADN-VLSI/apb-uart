//------------------------------------------------------------------------------
// APB Read Sequence
// Performs one APB register read. The caller sets 'addr' before starting the
// sequence and gets the value read back in 'rdata' after it finishes.
//------------------------------------------------------------------------------
class apb_read_seq extends uvm_sequence #(apb_seq_item);

  // Register the class with the UVM factory (sequences are objects, not components)
  `uvm_object_utils(apb_read_seq)

  //----------------------------------------------------------------------------
  // Fields
  //----------------------------------------------------------------------------
  bit [31:0] addr;                          // Register address to read (set by caller)
  bit [31:0] rdata;                         // Data read back from the DUT (result)

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name = "apb_read_seq");
    super.new(name);                        // Give the sequence an instance name
  endfunction

  //----------------------------------------------------------------------------
  // Body: runs when the sequence is started on a sequencer
  //----------------------------------------------------------------------------
  task body();
    // Create the transaction through the factory
    apb_seq_item req = apb_seq_item::type_id::create("req");

    start_item(req);                        // Request the sequencer; blocks until granted
    req.write = 1'b0;                       // 0 = read transfer
    req.addr  = addr;                       // Target register address
    req.data  = '0;                         // Write data is unused for a read
    finish_item(req);                       // Send to driver; returns after item_done()

    // The driver filled in rdata and error in the same object during the transfer
    rdata = req.rdata;                      // Pass the read value back to the caller

    // Report a slave error response (PSLVERR) from the DUT
    if (req.error) begin
      `uvm_error("APB_READ_ERROR",
                 $sformatf("read from 0x%08h returned PSLVERR", addr))
    end
  endtask

endclass
//------------------------------------------------------------------------------
// APB Sequence Item
// Transaction object created by APB sequences and consumed by the APB driver.
// Request fields (write, addr, data) are set by the sequence; response fields
// (rdata, error) are filled in by the driver after the bus transfer completes.
//------------------------------------------------------------------------------
class apb_seq_item extends uvm_sequence_item;

  //----------------------------------------------------------------------------
  // Request fields (randomizable, set by the sequence)
  //----------------------------------------------------------------------------
  rand bit        write;                    // 1 = write transfer, 0 = read transfer
  rand bit [31:0] addr;                     // Target register address (PADDR)
  rand bit [31:0] data;                     // Write data (PWDATA)

  //----------------------------------------------------------------------------
  // Response fields (not random, filled in by the driver)
  //----------------------------------------------------------------------------
  bit [31:0]      rdata;                    // Read data returned by the DUT (PRDATA)
  bit             error;                    // Slave error response (PSLVERR)

  //----------------------------------------------------------------------------
  // Factory registration and field automation
  // Enables print(), copy(), compare(), pack() etc. for all listed fields
  //----------------------------------------------------------------------------
  `uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(write, UVM_ALL_ON)
    `uvm_field_int(addr,  UVM_ALL_ON)
    `uvm_field_int(data,  UVM_ALL_ON)
    `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_field_int(error, UVM_ALL_ON)
  `uvm_object_utils_end

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name = "apb_seq_item");
    super.new(name);                        // Give the item an instance name
  endfunction

endclass
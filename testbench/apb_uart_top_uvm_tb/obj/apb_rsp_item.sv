//------------------------------------------------------------------------------
// APB Response Item
// Transaction object built by the APB monitor for every completed APB transfer.
// It carries what was actually observed on the bus (not what was requested)
// and is sent to the scoreboard through the monitor's analysis port.
//------------------------------------------------------------------------------
class apb_rsp_item extends uvm_sequence_item;

  //----------------------------------------------------------------------------
  // Fields
  //----------------------------------------------------------------------------
  bit        write;                         // 1 = write transfer, 0 = read transfer
  bit [31:0] addr;                          // Register address (PADDR)
  bit [31:0] data;                          // Write data (PWDATA)
  bit [31:0] rdata;                         // Read data returned by the DUT (PRDATA)
  bit        error;                         // Slave error response (PSLVERR)

  //----------------------------------------------------------------------------
  // Factory registration and field automation
  // Enables print(), copy(), compare(), pack() etc. for all listed fields
  //----------------------------------------------------------------------------
  `uvm_object_utils_begin(apb_rsp_item)
    `uvm_field_int(write, UVM_ALL_ON)
    `uvm_field_int(addr,  UVM_ALL_ON)
    `uvm_field_int(data,  UVM_ALL_ON)
    `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_field_int(error, UVM_ALL_ON)
  `uvm_object_utils_end

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name = "apb_rsp_item");
    super.new(name);                        // Give the item an instance name
  endfunction

endclass
//------------------------------------------------------------------------------
// APB Driver
// Takes APB sequence items from the sequencer and drives them onto the
// APB bus through the virtual interface.
//------------------------------------------------------------------------------
class apb_driver extends uvm_driver #(apb_seq_item);

  // Register the class with the UVM factory
  `uvm_component_utils(apb_driver)

  //----------------------------------------------------------------------------
  // Virtual interface handle
  //----------------------------------------------------------------------------
  virtual apb_if vif;                       // Connects the class world to the DUT pins

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);                // Place this component in the UVM hierarchy
  endfunction

  //----------------------------------------------------------------------------
  // Build phase: fetch the virtual interface from the config DB
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Stop the simulation if the top-level did not set "apb_vif"
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif)) begin
      `uvm_fatal("NOVIF", "apb_vif missing")
    end
  endfunction

  //----------------------------------------------------------------------------
  // Run phase: main driving loop
  //----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    apb_seq_item r;                         // Holds the current transaction

    forever begin
      seq_item_port.get_next_item(r);       // Block until the sequencer gives an item

      // Drive one APB transfer; read data and error are returned into r
      vif.do_transaction(r.write,           // 1 = write, 0 = read
                         r.addr,            // Target register address
                         r.data,            // Write data
                         4'hf,              // Byte strobe: all 4 bytes enabled
                         r.rdata,           // Read data returned from DUT
                         r.error);          // Slave error response

      seq_item_port.item_done();            // Tell the sequencer this item is finished
    end
  endtask

endclass
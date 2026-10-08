//------------------------------------------------------------------------------
// APB Monitor
// Passively observes the APB bus through the virtual interface, builds a
// response item for every completed transfer and broadcasts it through an
// analysis port (to the scoreboard or any other subscriber).
//------------------------------------------------------------------------------
class apb_monitor extends uvm_monitor;

  // Register the class with the UVM factory
  `uvm_component_utils(apb_monitor)

  //----------------------------------------------------------------------------
  // Handles
  //----------------------------------------------------------------------------
  virtual apb_if                 vif;       // Connects the class world to the DUT pins
  uvm_analysis_port #(apb_rsp_item) ap;     // Broadcasts observed transactions

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);                // Place this component in the UVM hierarchy
    ap = new("ap", this);                   // Analysis port must be created in new()
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
  // Run phase: sample the bus and publish transactions
  //----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    apb_rsp_item  t;                        // Transaction built from sampled signals

    // Local variables filled by the interface task
    logic         direction;                // 1 = write, 0 = read
    logic [31:0]  address;                  // Register address
    logic [31:0]  write_data;               // Data written to the DUT
    logic [31:0]  read_data;                // Data read back from the DUT
    logic [3:0]   write_strobe;             // Byte strobe (PSTRB)
    logic         slverr;                   // Slave error response (PSLVERR)

    forever begin
      // Block until one full APB transfer is observed on the bus
      vif.get_transaction(direction, address, write_data,
                          write_strobe, read_data, slverr);

      // Publish only if reset is inactive (arst_ni is active-low)
      if (vif.arst_ni) begin
        t = apb_rsp_item::type_id::create("t", this);  // Create a fresh item

        t.write = direction;                // Copy sampled values into the item
        t.addr  = address;
        t.data  = write_data;
        t.rdata = read_data;
        t.error = slverr;

        ap.write(t);                        // Send to all connected subscribers
      end
    end
  endtask

endclass
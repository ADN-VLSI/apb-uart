//------------------------------------------------------------------------------
// UART Driver
// Takes UART sequence items from the sequencer and serializes them onto the
// DUT's RX line through the virtual interface. Every byte sent is also
// published on rx_ap so the scoreboard knows what to expect on the APB side.
//------------------------------------------------------------------------------
class uart_driver extends uvm_driver #(uart_seq_item);

  // Register the class with the UVM factory
  `uvm_component_utils(uart_driver)

  //----------------------------------------------------------------------------
  // Handles
  //----------------------------------------------------------------------------
  virtual adn_uart_if             vif;      // Connects the class world to the DUT pins
  uvm_analysis_port #(uart_rsp_item) rx_ap; // Reports every byte sent into DUT RX

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);                // Place this component in the UVM hierarchy
    rx_ap = new("rx_ap", this);             // Analysis port must be created in new()
  endfunction

  //----------------------------------------------------------------------------
  // Build phase: fetch the virtual interface from the config DB
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Stop the simulation if the top-level did not set "uart_vif"
    if (!uvm_config_db#(virtual adn_uart_if)::get(this, "", "uart_vif", vif)) begin
      `uvm_fatal("NOVIF", "uart_vif missing")
    end
  endfunction

  //----------------------------------------------------------------------------
  // Run phase: main driving loop
  //----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    uart_seq_item r;                        // Item received from the sequencer
    uart_rsp_item observed;                 // Copy sent to the scoreboard

    vif.drive_enable = 0;                   // Start with the interface's drive control off

    forever begin
      seq_item_port.get_next_item(r);       // Block until the sequencer gives an item

      vif.send(r.data, r.baud);             // Serialize the byte at the requested baud rate

      // Report the transmitted byte to the scoreboard (expected on APB RXD)
      observed      = uart_rsp_item::type_id::create("observed");
      observed.data = r.data;
      rx_ap.write(observed);

      seq_item_port.item_done();            // Tell the sequencer this item is finished
    end
  endtask

endclass
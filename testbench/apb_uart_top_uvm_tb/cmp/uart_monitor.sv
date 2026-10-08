//------------------------------------------------------------------------------
// UART Monitor
// Watches the DUT's UART TX line, detects a start bit, samples 8 data bits
// at the middle of each bit period, checks the stop bit, and publishes the
// decoded byte on the analysis port (to the scoreboard).
//------------------------------------------------------------------------------
class uart_monitor extends uvm_monitor;

  // Register the class with the UVM factory
  `uvm_component_utils(uart_monitor)

  //----------------------------------------------------------------------------
  // Constants
  //----------------------------------------------------------------------------
  localparam int UART_BAUD = 9600;          // Fixed baud rate the monitor decodes at

  //----------------------------------------------------------------------------
  // Handles
  //----------------------------------------------------------------------------
  virtual adn_uart_if                vif;   // Connects the class world to the DUT pins
  uvm_analysis_port #(uart_rsp_item) ap;    // Broadcasts decoded UART bytes

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

    // Stop the simulation if the top-level did not set "uart_vif"
    if (!uvm_config_db#(virtual adn_uart_if)::get(this, "", "uart_vif", vif)) begin
      `uvm_fatal("NOVIF", "uart_vif missing")
    end
  endfunction

  //----------------------------------------------------------------------------
  // Run phase: detect and decode UART frames
  //----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    uart_rsp_item t;                        // Decoded frame sent to the scoreboard
    bit [7:0]     b;                        // Data byte being assembled
    time          bit_time;                 // Duration of one UART bit

    forever begin
      @(negedge vif.line);                  // Wait for a falling edge (possible start bit)

      if (vif.drive_enable) continue;       // Ignore edges while the testbench drives the line

      bit_time = 1s / UART_BAUD;            // One bit period at the configured baud rate

      // Wait half a bit and re-check the line is still low at the start-bit
      // midpoint. This rejects glitches and data edges mistaken for a start bit.
      #(bit_time / 2);
      if (vif.line !== 1'b0) continue;

      // Now at the center of the start bit; each further #(bit_time) lands at
      // the center of the next bit. Sample data bits LSB first.
      for (int i = 0; i < 8; i++) begin
        #(bit_time);
        b[i] = vif.line;
      end

      // Move to the center of the stop bit and build the transaction
      #(bit_time);
      t = uart_rsp_item::type_id::create("t", this);
      t.data          = b;                  // Decoded data byte
      t.framing_error = !vif.line;          // Stop bit must be 1; otherwise framing error
      ap.write(t);                          // Send to all connected subscribers
    end
  endtask

endclass
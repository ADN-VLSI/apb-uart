//------------------------------------------------------------------------------
// UART Agent
// Wraps the sequencer, driver and monitor for the UART interface.
// - Active  : sequencer + driver + monitor (drives the DUT RX line and
//             observes the DUT TX line)
// - Passive : monitor only (observes without driving)
//------------------------------------------------------------------------------
class uart_agent extends uvm_agent;

  // Register the class with the UVM factory (enables type_id::create and overrides)
  `uvm_component_utils(uart_agent)

  //----------------------------------------------------------------------------
  // Component handles
  //----------------------------------------------------------------------------
  uvm_sequencer #(uart_seq_item) sequencer;  // Passes seq items from sequence to driver
  uart_driver                    driver;     // Serializes seq items onto the UART RX line
  uart_monitor                   monitor;    // Samples the UART TX line and builds transactions

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);                 // Place this component in the UVM hierarchy
  endfunction

  //----------------------------------------------------------------------------
  // Build phase: create the child components
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Monitor is always created (needed in both active and passive modes)
    monitor = uart_monitor::type_id::create("monitor", this);

    // Sequencer and driver are created only in active mode
    if (is_active == UVM_ACTIVE) begin
      sequencer = uvm_sequencer#(uart_seq_item)::type_id::create("sequencer", this);
      driver    = uart_driver::type_id::create("driver", this);
    end
  endfunction

  //----------------------------------------------------------------------------
  // Connect phase: link the driver to the sequencer
  //----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Driver pulls items from the sequencer (get_next_item / item_done)
    if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction

endclass
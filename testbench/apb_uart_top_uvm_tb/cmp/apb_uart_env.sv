//------------------------------------------------------------------------------
// APB-UART Environment
// Top-level verification container. Holds the APB agent, UART agent and the
// scoreboard, and wires the monitors/driver outputs into the scoreboard.
//------------------------------------------------------------------------------
class apb_uart_env extends uvm_env;

  // Register the class with the UVM factory
  `uvm_component_utils(apb_uart_env)

  //----------------------------------------------------------------------------
  // Component handles
  //----------------------------------------------------------------------------
  apb_agent       apb;                      // Drives/observes the APB register interface
  uart_agent      uart;                     // Drives/observes the UART serial interface
  apb_uart_scbd   scbd;                     // Compares expected vs. actual behaviour

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);                // Place this component in the UVM hierarchy
  endfunction

  //----------------------------------------------------------------------------
  // Build phase: create the agents and the scoreboard
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    apb  = apb_agent::type_id::create("apb", this);          // APB agent
    uart = uart_agent::type_id::create("uart", this);        // UART agent
    scbd = apb_uart_scbd::type_id::create("scbd", this);     // Scoreboard
  endfunction

  //----------------------------------------------------------------------------
  // Connect phase: hook the analysis ports to the scoreboard
  //----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // APB transfers seen on the bus -> scoreboard
    apb.monitor.ap.connect(scbd.apb_imp);

    // Data the DUT transmits on the UART TX line -> scoreboard
    uart.monitor.ap.connect(scbd.uart_tx_imp);

    // Data the testbench drives into the DUT's UART RX line -> scoreboard
    uart.driver.rx_ap.connect(scbd.uart_rx_imp);
  endfunction

endclass
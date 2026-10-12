`ifndef __GUARD_APB_UART_ENV_SV__
`define __GUARD_APB_UART_ENV_SV__ 0

class apb_uart_env extends uvm_env;

  // ------------------------------------------------------------
  // UVM Component Registration
  // ------------------------------------------------------------

  `uvm_component_utils(apb_uart_env)

  // ------------------------------------------------------------
  // Environment Components
  // ------------------------------------------------------------

  apb_agent     apb_agent;
  uart_agent    uart_agent;
  apb_uart_scbd scbd;

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(
    string name = "apb_uart_env",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction : new

  // ------------------------------------------------------------
  // Build Phase
  // ------------------------------------------------------------

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Create APB agent.
    apb_agent = apb_agent::type_id::create(
      "apb_agent",
      this
    );

    // Create UART agent.
    uart_agent = uart_agent::type_id::create(
      "uart_agent",
      this
    );

    // Create scoreboard.
    scbd = apb_uart_scbd::type_id::create(
      "scbd",
      this
    );

  endfunction : build_phase

  // ------------------------------------------------------------
  // Connect Phase
  // ------------------------------------------------------------

  virtual function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    // APB monitor -> Scoreboard.
    apb_agent.monitor.ap.connect(
      scbd.apb_export
    );

    // UART monitor -> Scoreboard.
    uart_agent.monitor.ap.connect(
      scbd.uart_export
    );

  endfunction : connect_phase

endclass : apb_uart_env

`endif
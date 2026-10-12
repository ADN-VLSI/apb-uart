`ifndef __GUARD_UART_AGENT_SV__
`define __GUARD_UART_AGENT_SV__ 0

`include "component/uart_sequencer.sv"
`include "component/uart_driver.sv"
`include "component/uart_monitor.sv"

class uart_agent extends uvm_agent;

  // ------------------------------------------------------------
  // UVM Component Registration
  // ------------------------------------------------------------

  `uvm_component_utils(uart_agent)

  // ------------------------------------------------------------
  // Agent Components
  // ------------------------------------------------------------

  uart_sequencer sequencer;
  uart_driver    driver;
  uart_monitor   monitor;

  // ------------------------------------------------------------
  // Virtual Interface
  // ------------------------------------------------------------

  virtual uart_if vif;

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(string name = "uart_agent",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // ------------------------------------------------------------
  // Build Phase
  // ------------------------------------------------------------

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve UART virtual interface.
    if (!uvm_config_db#(virtual uart_if)::get(
          this, "", "vif", vif
        )) begin
      `uvm_fatal(
        get_type_name(),
        "UART virtual interface was not configured"
      )
    end

    // Monitor is always required.
    monitor = uart_monitor::type_id::create(
      "monitor", this
    );

    // Create active components only in active mode.
    if (get_is_active() == UVM_ACTIVE) begin

      sequencer = uart_sequencer::type_id::create(
        "sequencer", this
      );

      driver = uart_driver::type_id::create(
        "driver", this
      );

    end

  endfunction : build_phase

  // ------------------------------------------------------------
  // Connect Phase
  // ------------------------------------------------------------

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (get_is_active() == UVM_ACTIVE) begin

      // Connect UART sequencer to UART driver.
      driver.seq_item_port.connect(
        sequencer.seq_item_export
      );

    end

  endfunction : connect_phase

endclass : uart_agent

`endif
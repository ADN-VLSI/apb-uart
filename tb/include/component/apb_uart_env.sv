// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_APB_UART_ENV_SV__
`define __GUARD_APB_UART_ENV_SV__ 0

// Include component files for the environment
`include "component/apb_uart_scbd.sv"
`include "component/apb_agent.sv"
`include "component/uart_agent.sv"

// APB UART Environment
// This UVM environment contains the APB agent, UART agent, and scoreboard
// for verifying the APB-UART interface.
class apb_uart_env extends uvm_env;

  // UVM component utilities for factory registration
  `uvm_component_utils(apb_uart_env)

  // Environment components: APB agent, UART agent, scoreboard
  apb_agent apb;
  uart_agent uart;
  apb_uart_scbd scbd;

  // Constructor for the APB UART environment
  function new(string name = "apb_uart_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase: create sub-components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb  = apb_agent::type_id::create("apb", this);
    uart = uart_agent::type_id::create("uart", this);
    scbd = apb_uart_scbd::type_id::create("scbd", this);
  endfunction : build_phase

  // Connect phase: connect monitors to the scoreboard
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    apb.mon.ap.connect(scbd.m_analysis_imp_apb);
    uart.mon.ap.connect(scbd.m_analysis_imp_uart);
  endfunction : connect_phase
endclass

`endif

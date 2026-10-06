// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_APB_UART_ENV_SV__
`define __GUARD_APB_UART_ENV_SV__ 0

`include "component/apb_agent.sv"

// APB UART Environment
// This UVM environment contains the APB agent, UART agent, and scoreboard
// for verifying the APB-UART interface.
class apb_uart_env extends uvm_env;

  // UVM component utilities for factory registration
  `uvm_component_utils(apb_uart_env)

  // APB master agent
  apb_agent apb;

  // Constructor for the APB UART environment
  function new(string name = "apb_uart_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase: create sub-components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb  = apb_agent::type_id::create("apb", this);
  endfunction : build_phase
endclass

`endif
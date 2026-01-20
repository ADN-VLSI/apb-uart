// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_UART_AGENT_SV__
`define __GUARD_UART_AGENT_SV__ 0

// Include component and object files for the UART agent
`include "component/uart_seqr.sv"
`include "component/uart_dvr.sv"
`include "component/uart_mon.sv"
`include "object/uart_rsp_item.sv"

// UART Agent
// This UVM agent encapsulates the sequencer, driver, and monitor for UART transactions.
// It provides an analysis port for broadcasting response items.
class uart_agent extends uvm_agent;

  // UVM component utilities for factory registration
  `uvm_component_utils(uart_agent)

  // Agent components: sequencer, driver, monitor
  uart_seqr seqr;
  uart_dvr  dvr;
  uart_mon  mon;

  // Analysis port for sending response items to scoreboard or other components
  uvm_analysis_port #(uart_rsp_item) analysis_port;

  // Constructor for the UART agent
  function new(string name = "uart_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase: create sub-components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = uart_seqr::type_id::create("seqr", this);
    dvr  = uart_dvr::type_id::create("dvr", this);
    mon  = uart_mon::type_id::create("mon", this);
    analysis_port = new("analysis_port", this);
  endfunction : build_phase

  // Connect phase: connect driver to sequencer, monitor to analysis port
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dvr.seq_item_port.connect(seqr.seq_item_export);
    mon.ap.connect(analysis_port);
  endfunction : connect_phase

endclass

`endif

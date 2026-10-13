`ifndef __GUARD_UART_AGENT_SV__
`define __GUARD_UART_AGENT_SV__ 0

`include "apb_uart_uvm_tb/component/uart/uart_driver.sv"
`include "apb_uart_uvm_tb/component/uart/uart_monitor.sv"

class uart_agent extends uvm_agent;

  `uvm_component_utils(uart_agent)

  // Components inside the agent
  uvm_sequencer #(uart_seq_item) sqr;
  uart_driver    dvr;
  uart_monitor   mon;

  // Analysis port: sends monitor results out to the scoreboard
  uvm_analysis_port #(uart_resp_item) ap;

  function new (string name = "uart_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap  = new("ap", this);
    sqr = uvm_sequencer #(uart_seq_item)::type_id::create("sqr", this);
    dvr = uart_driver::type_id::create("dvr", this);
    mon = uart_monitor::type_id::create("mon", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Driver gets items from the sequencer
    dvr.seq_item_port.connect(sqr.seq_item_export);
    // Monitor results go out through the agent's port
    mon.ap.connect(ap);
  endfunction

endclass

`endif

`ifndef __GUARD_APB_AGENT_SV__
`define __GUARD_APB_AGENT_SV__ 0

`include "testbench/apb_uart_uvm_tb/component/apb/apb_driver.sv"
`include "testbench/apb_uart_uvm_tb/component/apb/apb_monitor.sv"

class apb_agent extends uvm_agent;

  `uvm_component_utils(apb_agent)

  // Components inside the agent
  uvm_sequencer #(apb_seq_item) sqr;
  apb_driver                    dvr;
  apb_monitor                   mon;

  // Analysis port: sends monitor results out to the scoreboard
  uvm_analysis_port #(apb_rsp_item) ap;

  function new (string name = "apb_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap  = new("ap", this);
    sqr = uvm_sequencer#(apb_seq_item)::type_id::create("sqr", this);
    dvr = apb_driver::type_id::create("dvr", this);
    mon = apb_monitor::type_id::create("mon", this);
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

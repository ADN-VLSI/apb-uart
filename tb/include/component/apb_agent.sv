// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_APB_AGENT_SV__
`define __GUARD_APB_AGENT_SV__ 0

// Include component and object files for the APB agent
`include "component/apb_seqr.sv"
`include "component/apb_dvr.sv"
`include "component/apb_mon.sv"
`include "object/apb_rsp_item.sv"

// APB Agent
// This UVM agent encapsulates the sequencer, driver, and monitor for APB transactions.
// It provides an analysis port for broadcasting response items.
class apb_agent extends uvm_agent;

  // UVM component utilities for factory registration
  `uvm_component_utils(apb_agent)

  // Agent components: sequencer, driver, monitor
  apb_seqr seqr;
  apb_dvr  dvr;
  apb_mon  mon;

  // Analysis port for sending response items to scoreboard or other components
  uvm_analysis_port #(apb_rsp_item) analysis_port;

  // Constructor for the APB agent
  function new(string name = "apb_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase: create sub-components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = apb_seqr::type_id::create("seqr", this);
    dvr  = apb_dvr::type_id::create("dvr", this);
    mon  = apb_mon::type_id::create("mon", this);
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

// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_APB_AGENT_SV__
`define __GUARD_APB_AGENT_SV__ 0

// Include component and object files for the APB agent
`include "component/apb_seq.sv"
`include "component/apb_dvr.sv"

// APB Agent
// This UVM agent encapsulates the sequencer, driver, and monitor for APB transactions.
// It provides an analysis port for broadcasting response items.
class apb_agent extends uvm_agent;

  // UVM component utilities for factory registration
  `uvm_component_utils(apb_agent)

  // Agent components: sequencer, driver, monitor
  apb_seq seqr;
  apb_dvr dvr;

  // Constructor for the APB agent
  function new(string name = "apb_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase: create sub-components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = apb_seq::type_id::create("seqr", this);
    dvr  = apb_dvr::type_id::create("dvr", this);
  endfunction : build_phase

  // Connect phase: connect driver to sequencer, monitor to analysis port
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dvr.seq_item_port.connect(seqr.seq_item_export);
  endfunction : connect_phase

endclass

`endif
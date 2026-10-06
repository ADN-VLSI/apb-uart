// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_APB_SEQR_SV__
`define __GUARD_APB_SEQR_SV__ 0

// Include the APB sequence item class
`include "apb/apb_seq_item.sv"

// APB Sequencer
// This UVM sequencer manages the sequencing of APB transactions
// to the driver.
class apb_seq extends uvm_sequencer #(apb_seq_item);

  // UVM component utilities for factory registration
  `uvm_component_utils(apb_seq)

  // Constructor for the APB sequencer
  function new(string name = "apb_seq", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass

`endif
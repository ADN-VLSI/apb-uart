`ifndef __GUARD_UART_SEQUENCER_SV__
`define __GUARD_UART_SEQUENCER_SV__ 0

`include "object/uart_seq_item.sv"
`include "object/uart_rsp_item.sv"

class uart_sequencer extends uvm_sequencer #(
  uart_seq_item,
  uart_rsp_item
);

  // ------------------------------------------------------------
  // UVM Component Registration
  // ------------------------------------------------------------

  `uvm_component_utils(uart_sequencer)

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(string name = "uart_sequencer",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : uart_sequencer

`endif
`ifndef APB_SEQR_SV
`define APB_SEQR_SV

class apb_seqr extends uvm_sequencer #(apb_seq_item, apb_rsp_item);
  `uvm_component_utils(apb_seqr)

  function new(string name = "apb_seqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass : apb_seqr

`endif  // APB_SEQR_SV

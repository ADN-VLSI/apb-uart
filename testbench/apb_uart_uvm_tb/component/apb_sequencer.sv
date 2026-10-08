`ifndef __GUARD_APB_SEQUENCER_SV__
`define __GUARD_APB_SEQUENCER_SV__ 0

class apb_sequencer extends uvm_sequencer #(apb_seq_item);

    `uvm_component_utils(apb_sequencer)

    function new(
        string name = "apb_sequencer",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

endclass

`endif
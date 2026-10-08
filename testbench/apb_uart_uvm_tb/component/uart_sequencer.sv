`ifndef __GUARD_UART_SEQUENCER_SV__
`define __GUARD_UART_SEQUENCER_SV__ 0

class uart_sequencer extends uvm_sequencer #(uart_seq_item);

    `uvm_component_utils(uart_sequencer)

    function new(
        string name = "uart_sequencer",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

endclass

`endif
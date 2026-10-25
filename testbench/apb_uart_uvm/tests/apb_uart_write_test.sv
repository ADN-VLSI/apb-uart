class apb_uart_write_test extends apb_uart_tx_test;

    `uvm_component_utils(apb_uart_write_test)

    function new(string name = "apb_uart_write_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass

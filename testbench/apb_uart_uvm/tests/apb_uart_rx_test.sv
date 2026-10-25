class apb_uart_rx_test extends apb_uart_base_test;

    `uvm_component_utils(apb_uart_rx_test)

    function new(string name = "apb_uart_rx_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        uart_rx_seq seq;

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "TEST START: UART RX test; inject 5 bytes (00, FF, 55, AA, A5) using 8-N-1 framing",
                  UVM_LOW)

        seq = uart_rx_seq::type_id::create("seq");

        seq.start(env.uart.sequencer);

        #1000;

        `uvm_info(get_type_name(),
                  "TEST COMPLETE: all 5 UART RX input frames were driven",
                  UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass

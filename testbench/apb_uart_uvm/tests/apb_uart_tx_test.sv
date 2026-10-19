class apb_uart_tx_test extends apb_uart_base_test;

    `uvm_component_utils(apb_uart_tx_test)

    function new(string name = "apb_uart_tx_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        apb_write_seq seq;

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "UART TX Test Started",
                  UVM_LOW)

        seq = apb_write_seq::type_id::create("seq");

        seq.addr = 32'h0000001C;
        seq.data = 32'h000000A5;

        seq.start(env.apb.sequencer);

        `uvm_info(get_type_name(),
                  "UART TX Data Written: 0xA5",
                  UVM_LOW)

        #1000;

        phase.drop_objection(this);
    endtask

endclass
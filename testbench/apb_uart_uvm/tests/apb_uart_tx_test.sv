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
                  "TEST START: UART TX test; write one byte to the UART transmit data register",
                  UVM_LOW)

        seq = apb_write_seq::type_id::create("seq");

        seq.addr = 32'h0000001C;
        seq.data = 32'h000000A5;

        `uvm_info(get_type_name(),
                  $sformatf("STEP 1: APB write register=UART_TXD address=0x%08h data=0x%08h; expected UART byte=0x%02h",
                            seq.addr, seq.data, seq.data[7:0]),
                  UVM_LOW)

        seq.start(env.apb.sequencer);

        `uvm_info(get_type_name(),
                  $sformatf("STEP 1 COMPLETE: APB write accepted for UART_TXD address=0x%08h data=0x%08h (UART byte=0x%02h)",
                            seq.addr, seq.data, seq.data[7:0]),
                  UVM_LOW)

        #1000;

        `uvm_info(get_type_name(),
                  "TEST COMPLETE: UART TX stimulus finished; see UART scoreboard messages for observed frames and framing errors",
                  UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass
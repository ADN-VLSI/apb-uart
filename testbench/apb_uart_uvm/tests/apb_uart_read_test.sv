class apb_uart_read_test extends apb_uart_base_test;

    `uvm_component_utils(apb_uart_read_test)

    function new(string name = "apb_uart_read_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        localparam bit [31:0] UART_CFG_ADDR = 32'h00000004;
        localparam bit [31:0] UART_CFG_RESET = 32'h0003405B;
        apb_read_seq read_seq;

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "TEST START: read the UART configuration register over APB",
                  UVM_LOW)

        `uvm_info(get_type_name(),
                  $sformatf("STEP 1: read register=UART_CFG address=0x%08h (expected reset value=0x%08h)",
                            UART_CFG_ADDR, UART_CFG_RESET),
                  UVM_LOW)

        read_seq = apb_read_seq::type_id::create("read_seq");
        read_seq.addr = UART_CFG_ADDR;
        read_seq.start(env.apb.sequencer);

        `uvm_info(get_type_name(),
                  $sformatf("RESULT: register=UART_CFG address=0x%08h read_data=0x%08h expected=0x%08h",
                            UART_CFG_ADDR, read_seq.read_data, UART_CFG_RESET),
                  UVM_LOW)

        if (read_seq.read_data !== UART_CFG_RESET)
            `uvm_error(get_type_name(),
                       $sformatf("UART_CFG reset value mismatch: expected 0x%08h, got 0x%08h",
                                 UART_CFG_RESET, read_seq.read_data))

        `uvm_info(get_type_name(),
                  "TEST COMPLETE: UART_CFG APB read finished",
                  UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass
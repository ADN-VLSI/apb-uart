class apb_uart_reg_test extends apb_uart_base_test;

    `uvm_component_utils(apb_uart_reg_test)

    function new(string name = "apb_uart_reg_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        localparam bit [31:0] UART_INT_ADDR = 32'h00000030;
        localparam bit [31:0] UART_INT_READ_MASK = 32'h0000000F;
        apb_access_seq write_seq;
        apb_access_seq read_seq;

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "TEST START: APB register write/read test",
                  UVM_LOW)

        wait (env.apb.driver.vif.PRESETn === 1'b1);
        env.sb.enable_apb_transaction_counting();

        `uvm_info(get_type_name(),
                                    "STEP 1: write randomized interrupt enables to UART_INT",
                  UVM_LOW)

        write_seq = apb_access_seq::type_id::create("write_seq");
        if (!write_seq.randomize() with {
                is_write == 1'b1;
                                addr == UART_INT_ADDR;
                                data inside {[32'h00000000:UART_INT_READ_MASK]};
            })
            `uvm_fatal(get_type_name(), "APB register write randomization failed")

                env.sb.expect_apb_read(UART_INT_ADDR,
                                                             write_seq.data & UART_INT_READ_MASK,
                                                             UART_INT_READ_MASK);

        `uvm_info(get_type_name(),
                  $sformatf("Randomized write data=0x%08h", write_seq.data),
                  UVM_LOW)
        write_seq.start(env.apb.sequencer);

        `uvm_info(get_type_name(),
                                    "STEP 2: read back UART_INT",
                  UVM_LOW)

        read_seq = apb_access_seq::type_id::create("read_seq");
        read_seq.is_write = 1'b0;
                read_seq.addr = UART_INT_ADDR;
        read_seq.start(env.apb.sequencer);

        `uvm_info(get_type_name(),
                  $sformatf("RESULT: address=0x%08h written=0x%08h read_back=0x%08h",
                            write_seq.addr, write_seq.data, read_seq.read_data),
                  UVM_LOW)

        `uvm_info(get_type_name(),
                  "TEST COMPLETE: APB register write/read sequence finished",
                  UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass
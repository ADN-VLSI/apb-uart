class apb_uart_reg_test extends apb_uart_base_test;

    `uvm_component_utils(apb_uart_reg_test)

    function new(string name = "apb_uart_reg_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        apb_write_seq write_seq;
        apb_read_seq read_seq;

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "TEST START: APB register write/read test",
                  UVM_LOW)

        `uvm_info(get_type_name(),
                  "STEP 1: write 0x000000A5 to APB address 0x00000000",
                  UVM_LOW)

        write_seq = apb_write_seq::type_id::create("write_seq");
        write_seq.addr = 32'h00000000;
        write_seq.data = 32'h000000A5;
        write_seq.start(env.apb.sequencer);

        `uvm_info(get_type_name(),
                  "STEP 2: read back APB address 0x00000000",
                  UVM_LOW)

        read_seq = apb_read_seq::type_id::create("read_seq");
        read_seq.addr = 32'h00000000;
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
class apb_uart_base_test extends uvm_test;

    `uvm_component_utils(apb_uart_base_test)

    apb_uart_env env;

    function new(string name = "apb_uart_base_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = apb_uart_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "TEST START: APB UART base smoke test; checking that the testbench environment runs",
                  UVM_LOW)

        #100;

        `uvm_info(get_type_name(),
                  "TEST COMPLETE: base smoke test finished; no APB or UART transactions were issued",
                  UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass
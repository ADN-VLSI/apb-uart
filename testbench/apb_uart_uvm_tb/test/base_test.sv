`ifndef BASE_TEST_SV
`define BASE_TEST_SV

class base_test extends uvm_test;

    `uvm_component_utils(base_test)


    // ------------------------------------------------------------
    // Environment
    // ------------------------------------------------------------

    apb_uart_env env;


    // ------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------

    function new(
        string name = "base_test",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    // ------------------------------------------------------------
    // Build
    // ------------------------------------------------------------

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env =
            apb_uart_env::type_id::create(
                "env",
                this
            );

    endfunction


    // ------------------------------------------------------------
    // End of elaboration
    // ------------------------------------------------------------

    function void end_of_elaboration_phase(
        uvm_phase phase
    );

        super.end_of_elaboration_phase(phase);

        `uvm_info(
            get_type_name(),
            "UVM testbench hierarchy constructed",
            UVM_LOW
        )

    endfunction


    // ------------------------------------------------------------
    // Run
    // ------------------------------------------------------------

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        // Small startup delay
        #100ns;

        phase.drop_objection(this);

    endtask

endclass

`endif
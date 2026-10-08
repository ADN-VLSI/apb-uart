`ifndef BASIC_WRITE_TEST_SV
`define BASIC_WRITE_TEST_SV

class basic_write_test extends base_test;

    `uvm_component_utils(basic_write_test)

    import uart_reg_if_pkg::*;

    function new(
        string name = "basic_write_test",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    task run_phase(uvm_phase phase);

        apb_base_seq seq;

        phase.raise_objection(this);


        seq = apb_base_seq::type_id::create(
            "seq"
        );


        // --------------------------------------------------------
        // CTRL
        // --------------------------------------------------------

        seq.apb_write(
            ADDR_CTRL,
            32'h0000_0018
        );


        // --------------------------------------------------------
        // CFG
        // --------------------------------------------------------

        seq.apb_write(
            ADDR_CFG,
            32'h0004_005B
        );


        // --------------------------------------------------------
        // TX data
        // --------------------------------------------------------

        seq.apb_write(
            ADDR_TXD,
            32'h0000_0055
        );


        // --------------------------------------------------------
        // Interrupt enable
        // --------------------------------------------------------

        seq.apb_write(
            ADDR_INTR,
            32'h0000_000F
        );


        phase.drop_objection(this);

    endtask

endclass

`endif
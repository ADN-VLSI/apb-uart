`ifndef UART_TX_TEST_SV
`define UART_TX_TEST_SV

class uart_tx_test extends base_test;

    `uvm_component_utils(uart_tx_test)

    function new(
        string name = "uart_tx_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);

        uart_en_apb_seq uart_cfg_seq;
        apb_base_seq    tx_seq;

        phase.raise_objection(this);


        // --------------------------------------------------------
        // Configure UART
        // --------------------------------------------------------

        uart_cfg_seq =
            uart_en_apb_seq::type_id::create(
                "uart_cfg_seq"
            );

        uart_cfg_seq.start(
            env.apb_agent_h.sequencer
        );


        // --------------------------------------------------------
        // Send data through TX FIFO
        // --------------------------------------------------------

        tx_seq =
            apb_base_seq::type_id::create(
                "tx_seq"
            );

        tx_seq.apb_write(
            ADDR_TXD,
            32'h0000_0055
        );

        tx_seq.apb_write(
            ADDR_TXD,
            32'h0000_AA
        );

        tx_seq.apb_write(
            ADDR_TXD,
            32'h0000_F0
        );


        // Give UART enough time to transmit
        #100us;


        phase.drop_objection(this);

    endtask

endclass

`endif
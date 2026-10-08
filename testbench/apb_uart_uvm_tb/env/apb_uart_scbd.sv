`ifndef APB_UART_SCBD_SV
`define APB_UART_SCBD_SV

class apb_uart_scbd extends uvm_scoreboard;

    `uvm_component_utils(apb_uart_scbd)


    // ------------------------------------------------------------
    // Analysis FIFOs
    // ------------------------------------------------------------

    uvm_tlm_analysis_fifo #(apb_seq_item) apb_fifo;

    uvm_tlm_analysis_fifo #(uart_rsp_item) uart_fifo;


    // ------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------

    function new(
        string name = "apb_uart_scbd",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    // ------------------------------------------------------------
    // Build
    // ------------------------------------------------------------

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        apb_fifo = new(
            "apb_fifo",
            this
        );

        uart_fifo = new(
            "uart_fifo",
            this
        );

    endfunction


    // ------------------------------------------------------------
    // Run
    // ------------------------------------------------------------

    task run_phase(uvm_phase phase);

        fork

            process_apb();

            process_uart();

        join

    endtask


    // ------------------------------------------------------------
    // APB checking
    // ------------------------------------------------------------

    task process_apb();

        apb_seq_item item;

        forever begin

            apb_fifo.get(item);

            `uvm_info(
                get_type_name(),
                $sformatf(
                    "APB transaction observed: %s",
                    item.convert2string()
                ),
                UVM_HIGH
            );

        end

    endtask


    // ------------------------------------------------------------
    // UART checking
    // ------------------------------------------------------------

    task process_uart();

        uart_rsp_item item;

        forever begin

            uart_fifo.get(item);

            `uvm_info(
                get_type_name(),
                $sformatf(
                    "UART transaction observed: %s",
                    item.convert2string()
                ),
                UVM_HIGH
            );

        end

    endtask

endclass

`endif
`ifndef __GUARD_UART_DRIVER_SV__
`define __GUARD_UART_DRIVER_SV__ 0

class uart_driver extends uvm_driver #(uart_seq_item);

    `uvm_component_utils(uart_driver)

    virtual uart_if vif;


    function new(
        string name = "uart_driver",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual uart_if)::get(
                this,
                "",
                "vif",
                vif
            )) begin

            `uvm_fatal(
                get_type_name(),
                "UART virtual interface not found"
            )

        end

    endfunction


    task run_phase(uvm_phase phase);

        uart_seq_item req;

        // UART idle state
        vif.uart_rx <= 1'b1;

        forever begin

            seq_item_port.get_next_item(req);

            drive_uart(req);

            seq_item_port.item_done();

        end

    endtask


    virtual task drive_uart(uart_seq_item req);

        bit parity;

        `uvm_info(
            get_type_name(),
            $sformatf(
                "Driving UART byte: 0x%02h",
                req.data
            ),
            UVM_MEDIUM
        )


        // --------------------------------------------------------
        // Start bit
        // --------------------------------------------------------

        vif.uart_rx <= 1'b0;
        uart_bit_delay();


        // --------------------------------------------------------
        // Data bits
        // --------------------------------------------------------

        for (int i = 0; i < 8; i++) begin

            vif.uart_rx <= req.data[i];

            uart_bit_delay();

        end


        // --------------------------------------------------------
        // Parity
        // --------------------------------------------------------

        if (req.parity_en) begin

            parity = ^req.data;

            if (req.parity_type)
                parity = ~parity;

            if (req.inject_parity_error)
                parity = ~parity;

            vif.uart_rx <= parity;

            uart_bit_delay();

        end


        // --------------------------------------------------------
        // Stop bit
        // --------------------------------------------------------

        vif.uart_rx <= 1'b1;

        uart_bit_delay();


        // --------------------------------------------------------
        // Extra stop bit
        // --------------------------------------------------------

        if (req.stop_bits) begin
            vif.uart_rx <= 1'b1;
            uart_bit_delay();
        end


        // UART idle
        vif.uart_rx <= 1'b1;

    endtask


    virtual task uart_bit_delay();

        // Placeholder.
        // Replace with your actual UART baud-rate timing.
        //
        // Example:
        // #(UART_BIT_TIME);

        repeat (10) @(posedge vif.PCLK);

    endtask

endclass

`endif

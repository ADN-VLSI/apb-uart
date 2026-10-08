`ifndef __GUARD_UART_MONITOR_SV__
`define __GUARD_UART_MONITOR_SV__ 0

class uart_monitor extends uvm_monitor;

    `uvm_component_utils(uart_monitor)

    virtual uart_if vif;

    uvm_analysis_port #(uart_rsp_item) uart_analysis_port;


    function new(
        string name = "uart_monitor",
        uvm_component parent = null
    );
        super.new(name, parent);

        uart_analysis_port =
            new("uart_analysis_port", this);
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

        forever begin

            wait_for_start_bit();

            collect_uart_frame();

        end

    endtask


    virtual task wait_for_start_bit();

        // UART TX idle = 1
        // Start bit = 0

        @(negedge vif.uart_tx);

    endtask


    virtual task collect_uart_frame();

        uart_rsp_item item;

        bit [7:0] data;
        bit       parity;
        bit       expected_parity;

        item = uart_rsp_item::type_id::create(
            "item",
            this
        );

        // --------------------------------------------------------
        // Move to center of first data bit
        // --------------------------------------------------------

        uart_half_bit_delay();


        // --------------------------------------------------------
        // Data bits
        // --------------------------------------------------------

        for (int i = 0; i < 8; i++) begin

            uart_bit_delay();

            data[i] = vif.uart_tx;

        end


        item.data      = data;
        item.valid     = 1'b1;
        item.direction = 1'b1;


        // --------------------------------------------------------
        // Publish transaction
        // --------------------------------------------------------

        `uvm_info(
            get_type_name(),
            item.convert2string(),
            UVM_MEDIUM
        )

        uart_analysis_port.write(item);


        // --------------------------------------------------------
        // Wait until frame is complete
        // --------------------------------------------------------

        uart_bit_delay();

    endtask


    virtual task uart_bit_delay();

        repeat (10) @(posedge vif.PCLK);

    endtask


    virtual task uart_half_bit_delay();

        repeat (5) @(posedge vif.PCLK);

    endtask

endclass

`endif
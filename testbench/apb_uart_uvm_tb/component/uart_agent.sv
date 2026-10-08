`ifndef __GUARD_UART_AGENT_SV__
`define __GUARD_UART_AGENT_SV__ 0

class uart_agent extends uvm_agent;

    `uvm_component_utils(uart_agent)

    uart_sequencer sequencer;
    uart_driver    driver;
    uart_monitor   monitor;


    function new(
        string name = "uart_agent",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        monitor = uart_monitor::type_id::create(
            "monitor",
            this
        );

        if (is_active == UVM_ACTIVE) begin

            sequencer = uart_sequencer::type_id::create(
                "sequencer",
                this
            );

            driver = uart_driver::type_id::create(
                "driver",
                this
            );

        end

    endfunction


    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        if (is_active == UVM_ACTIVE) begin

            driver.seq_item_port.connect(
                sequencer.seq_item_export
            );

        end

    endfunction

endclass

`endif
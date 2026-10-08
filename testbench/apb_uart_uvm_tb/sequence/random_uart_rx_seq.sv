`ifndef __GUARD_RANDOM_UART_RX_SEQ_SV__
`define __GUARD_RANDOM_UART_RX_SEQ_SV__ 0

class random_uart_rx_seq extends uart_base_seq;

    `uvm_object_utils(random_uart_rx_seq)

    rand int unsigned num_bytes;

    constraint num_bytes_c {
        num_bytes inside {[1:100]};
    }

    function new(string name = "random_uart_rx_seq");
        super.new(name);
    endfunction


    virtual task body();

        uart_seq_item req;

        if (!randomize()) begin
            `uvm_fatal(
                get_type_name(),
                "Failed to randomize random_uart_rx_seq"
            )
        end

        `uvm_info(
            get_type_name(),
            $sformatf(
                "Starting random UART RX sequence, bytes=%0d",
                num_bytes
            ),
            UVM_MEDIUM
        )

        repeat (num_bytes) begin

            req = uart_seq_item::type_id::create("req");

            start_item(req);

            if (!req.randomize() with {
                direction == 1'b0;
                inject_parity_error == 1'b0;
                inject_frame_error  == 1'b0;
            }) begin

                `uvm_fatal(
                    get_type_name(),
                    "Failed to randomize UART RX transaction"
                )

            end

            finish_item(req);

        end

    endtask

endclass

`endif
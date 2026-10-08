`ifndef __GUARD_UART_BASE_SEQ_SV__
`define __GUARD_UART_BASE_SEQ_SV__ 0

class uart_base_seq extends uvm_sequence #(uart_seq_item);

    `uvm_object_utils(uart_base_seq)

    function new(string name = "uart_base_seq");
        super.new(name);
    endfunction


    // ------------------------------------------------------------
    // Send one UART byte
    // ------------------------------------------------------------
    virtual task send_byte(
        input bit [7:0] data
    );

        uart_seq_item req;

        req = uart_seq_item::type_id::create("req");

        start_item(req);

        req.data      = data;
        req.direction = 1'b0;

        finish_item(req);

    endtask


    // ------------------------------------------------------------
    // Send multiple bytes
    // ------------------------------------------------------------
    virtual task send_bytes(
        input bit [7:0] data[]
    );

        foreach (data[i]) begin
            send_byte(data[i]);
        end

    endtask

endclass

`endif
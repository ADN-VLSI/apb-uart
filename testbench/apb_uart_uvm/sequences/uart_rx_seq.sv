class uart_rx_seq extends uvm_sequence #(uart_seq_item);

  `uvm_object_utils(uart_rx_seq)

  function new(string name = "uart_rx_seq");
    super.new(name);
  endfunction

  task body();

    uart_seq_item req;

    bit [7:0] test_data[5] = '{
      8'h00,
      8'hFF,
      8'h55,
      8'hAA,
      8'hA5
    };

    foreach (test_data[i]) begin

      req = uart_seq_item::type_id::create("req");

      start_item(req);

      req.data       = test_data[i];
      req.data_bits  = 2'b11;  // 8 data bits
      req.parity_en  = 1'b0;   // No parity
      req.parity_type = 1'b0;
      req.stop_bits  = 1'b0;   // One stop bit

      finish_item(req);

      `uvm_info("UART_RX_SEQ",
                $sformatf("Sending UART RX data: 0x%02h",
                          req.data),
                UVM_MEDIUM)

    end

  endtask

endclass
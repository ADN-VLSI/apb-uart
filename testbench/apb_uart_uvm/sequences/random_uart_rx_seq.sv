class uart_rx_seq extends uvm_sequence #(uart_seq_item);

  `uvm_object_utils(uart_rx_seq)

  bit [7:0] driven_data[$];
  int unsigned frame_count = 5;

  function new(string name = "uart_rx_seq");
    super.new(name);
  endfunction

  virtual task body();

    uart_seq_item req;
    int unsigned driven_count = 0;

    driven_data.delete();

    for (int unsigned i = 0; i < frame_count; i++) begin

      req = uart_seq_item::type_id::create("req");

      start_item(req);

      if (!req.randomize() with {
            data_bits == 2'b11;
            parity_en == 1'b0;
            parity_type == 1'b0;
            stop_bits == 1'b0;
          }) begin
        `uvm_fatal("UART_RX_RAND", "UART RX randomization failed")
      end

      finish_item(req);
        driven_data.push_back(req.data);
        driven_count++;

      `uvm_info("UART_RX_SEQ",
                $sformatf("UART RX randomized input: frame %0d/%0d, data=0x%02h, format=8-N-1",
                  i + 1, frame_count, req.data),
                UVM_LOW)

    end

    `uvm_info("UART_RX_SEQ",
              $sformatf("UART RX sequence frames driven: %0d/%0d",
                        driven_count, frame_count),
              UVM_LOW)

  endtask

endclass
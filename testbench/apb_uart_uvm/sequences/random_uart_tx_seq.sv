class uart_tx_seq extends uvm_sequence #(uart_seq_item);

  `uvm_object_utils(uart_tx_seq)

  function new(string name = "uart_tx_seq");
    super.new(name);
  endfunction

  virtual task body();

    uart_seq_item req;
    int seq_length;
    int unsigned driven_count = 0;

    if (!uvm_config_db#(int)::get(
          uvm_root::get(), "parameter", "RANDOM_UART_TX_SEQ_LENGTH", seq_length
        ))
      seq_length = 11;

    repeat (seq_length) begin

      req = uart_seq_item::type_id::create("req");

      start_item(req);

      if (!req.randomize()) begin

        `uvm_fatal("UART_TX_RAND",
                   "UART TX randomization failed")

      end

      finish_item(req);
      driven_count++;

      `uvm_info("UART_TX_SEQ",
                $sformatf(
                  "Data=0x%02h DataBits=%0d ParityEn=%0b ParityType=%0b ExtraStop=%0b",
                  req.data,
                  5 + int'(req.data_bits),
                  req.parity_en,
                  req.parity_type,
                  req.stop_bits
                ),
                UVM_MEDIUM)

    end

    `uvm_info("UART_TX_SEQ",
              $sformatf("UART TX sequence items driven: %0d/%0d",
                        driven_count, seq_length),
              UVM_LOW)

  endtask

endclass
class uart_tx_seq extends uvm_sequence #(uart_seq_item);

  `uvm_object_utils(uart_tx_seq)

  function new(string name = "uart_tx_seq");
    super.new(name);
  endfunction

  task body();

    uart_seq_item req;

    repeat (10) begin

      req = uart_seq_item::type_id::create("req");

      start_item(req);

      if (!req.randomize()) begin

        `uvm_fatal("UART_TX_RAND",
                   "UART TX randomization failed")

      end

      finish_item(req);

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

  endtask

endclass
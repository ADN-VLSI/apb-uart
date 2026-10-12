`ifndef __GUARD_RANDOM_UART_RX_SEQ_SV__
`define __GUARD_RANDOM_UART_RX_SEQ_SV__ 0

`include "uart_base_seq.sv"

class random_uart_rx_seq extends uart_base_seq;

  `uvm_object_utils(random_uart_rx_seq)

  rand int unsigned num_transactions;

  constraint num_transactions_c {
    num_transactions inside {[10:50]};
  }

  function new(string name = "random_uart_rx_seq");
    super.new(name);
  endfunction

  virtual task body();

    uart_seq_item req;

    if (!randomize()) begin
      `uvm_fatal(get_type_name(), "Failed to randomize sequence configuration")
    end

    `uvm_info(
      get_type_name(),
      $sformatf("Starting %0d randomized UART frames", num_transactions),
      UVM_LOW
    )

    repeat (num_transactions) begin

      req = uart_seq_item::type_id::create("req");

      start_item(req);

      if (!req.randomize()) begin
        `uvm_fatal(get_type_name(), "Failed to randomize UART transaction")
      end

      `uvm_info(
        get_type_name(),
        $sformatf("Random UART RX: %s", req.to_string()),
        UVM_MEDIUM
      )

      finish_item(req);

    end

    `uvm_info(get_type_name(), "Random UART frames completed", UVM_LOW)

  endtask : body

endclass

`endif
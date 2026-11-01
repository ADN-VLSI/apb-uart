`ifndef __GUARD_RANDOM_UART_RX_SEQ_SV__
`define __GUARD_RANDOM_UART_RX_SEQ_SV__ 0

`include "apb_uart_uvm_tb/sequence/apb_uart_base_seq.sv"

class random_uart_rx_seq extends apb_uart_base_seq;

  `uvm_object_utils(random_uart_rx_seq)

  rand int unsigned num_transactions;

  constraint num_transactions_c {num_transactions inside {[10 : 50]};}

  function new(string name = "random_uart_rx_seq");
    super.new(name);
  endfunction

  virtual task body();

    logic [7:0] tx_data;
    bit rand_ok;
    time bit_time;

    rand_ok = this.randomize();
    if (!rand_ok) begin
      `uvm_fatal(get_type_name(), "Sequence randomization failed")
    end

    `uvm_info(get_type_name(), $sformatf("Starting DUT TX test with %0d bytes", num_transactions),
              UVM_LOW)

    // UART configuration
    apb_write(6'h04, 32'h0003405B);

    // TX only, not TX+RX
    apb_write(6'h00, 32'h00000008);

    bit_time = 1s / 108695;  // must match the real DUT UART baud

    for (int unsigned i = 0; i < num_transactions; i++) begin
      tx_data = $urandom();

      apb_write(6'h10, 32'h80000001);
      apb_write(6'h1C, {24'h0, tx_data});

      // full frame spacing between bytes
      #(10 * bit_time);
    end

    `uvm_info(get_type_name(), "All TX data writes completed", UVM_LOW)

  endtask

endclass : random_uart_rx_seq

`endif

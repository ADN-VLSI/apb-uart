// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_RANDOM_UART_RX_SEQ_SV__
`define __GUARD_RANDOM_UART_RX_SEQ_SV__ 0

// Random UART RX Sequence
// Generates a configurable number of randomized 8-N-1 UART receive transactions.
class random_uart_rx_seq extends uvm_sequence #(uart_seq_item);

  `uvm_object_utils(random_uart_rx_seq)

  bit [7:0] driven_data[$];

  function new(string name = "random_uart_rx_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    int seq_length;

    driven_data.delete();

    if (!uvm_config_db#(int)::get(
            uvm_root::get(), "parameter", "RANDOM_UART_RX_SEQ_LENGTH", seq_length
        ))
      seq_length = 10;

    repeat (seq_length) begin
      `uvm_do_with(req, {
        data_bits == 2'b11;
        parity_en == 1'b0;
        parity_type == 1'b0;
        stop_bits == 1'b0;
      })
      driven_data.push_back(req.data);
    end
  endtask : body

endclass

`endif

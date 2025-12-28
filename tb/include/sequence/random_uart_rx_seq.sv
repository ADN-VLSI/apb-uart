`ifndef __GUARD_RANDOM_UART_RX_SEQ_SV__
`define __GUARD_RANDOM_UART_RX_SEQ_SV__ 0



`include "object/uart_seq_item.sv"

class random_uart_rx_seq extends uvm_sequence #(uart_seq_item);

  `uvm_object_utils(random_uart_rx_seq)

  function new(string name = "random_uart_rx_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    int seq_length;
    if (!uvm_config_db#(int)::get(
            uvm_root::get(), "parameter", "RANDOM_UART_RX_SEQ_LENGTH", seq_length
        ))
      seq_length = 1;
    repeat (seq_length) begin
      `uvm_do(req)
    end
  endtask : body

endclass


`endif

`ifndef __GUARD_RANDOM_UART_RX_SEQ_SV__
`define __GUARD_RANDOM_UART_RX_SEQ_SV__ 0

`include "apb_uart_uvm_tb/object/uart_seq_item.sv"

// Sequence: send random bytes into the DUT on the UART RX line.
// How many bytes: set RANDOM_UART_RX_SEQ_LENGTH in the config DB (default 1).
//
// The line settings must match what apb_uart_init_seq programs into CFG
// (baud_div = 868, 8 data bits, no parity, one stop bit).
//
// Baud rate: the DUT's receiver samples every bit 8 times on the divided clock
// (OVERSAMPLE = 8), so one received bit lasts 8 divided-clock cycles:
//   RX baud = PCLK / (8 * baud_div) = 100 MHz / (8 * 868) = about 14400
// The DUT's transmitter sends one bit per divided-clock cycle (115200 baud
// for the same setting). Check with the DUT designer that this difference is intended.
class random_uart_rx_seq extends uvm_sequence #(uart_seq_item);

  `uvm_object_utils(random_uart_rx_seq)

  function new (string name = "random_uart_rx_seq");
    super.new(name);
  endfunction

  virtual task body();
    int seq_length;

    // Number of bytes (use 1 if the test did not set it)
    if (!uvm_config_db#(int)::get(uvm_root::get(), "parameter", "RANDOM_UART_RX_SEQ_LENGTH", seq_length)) begin
      seq_length = 1;
    end

    repeat (seq_length) begin
      // data is random; the line settings are fixed
      `uvm_do_with(req, {
        baud_rate   == 14400;
        parity_en   == 0;
        parity_type == 0;
        extra_stop  == 0;
        data_bits   == 8;
      })
    end
  endtask

endclass

`endif
`ifndef __GUARD_RANDOM_UART_RX_SEQ_SV__
`define __GUARD_RANDOM_UART_RX_SEQ_SV__ 0

`include "apb_uart_uvm_tb/object/uart_seq_item.sv"

// Sequence: send random bytes into the DUT on the UART RX line.
// How many bytes: set RANDOM_UART_RX_SEQ_LENGTH in the config DB (default 1).
//
// The line settings must match what apb_uart_init_seq programs into CFG
// (baud_div = 868, 8 data bits, no parity, one stop bit).
//
// Baud rate: the DUT's receiver samples every bit 8 times on the divided clock
// (OVERSAMPLE = 8), so one received bit lasts 8 divided-clock cycles:
//   RX baud = PCLK / (8 * baud_div) = 100 MHz / (8 * 868) = about 14400
// The DUT's transmitter sends one bit per divided-clock cycle (115200 baud
// for the same setting). Check with the DUT designer that this difference is intended.
class random_uart_rx_seq extends uvm_sequence #(uart_seq_item);

  `uvm_object_utils(random_uart_rx_seq)

  function new (string name = "random_uart_rx_seq");
    super.new(name);
  endfunction

  virtual task body();
    int seq_length;

    // Number of bytes (use 1 if the test did not set it)
    if (!uvm_config_db#(int)::get(uvm_root::get(), "parameter", "RANDOM_UART_RX_SEQ_LENGTH", seq_length)) begin
      seq_length = 1;
    end

    repeat (seq_length) begin
      // data is random; the line settings are fixed
      `uvm_do_with(req, {
        baud_rate   == 14400;
        parity_en   == 0;
        parity_type == 0;
        extra_stop  == 0;
        data_bits   == 8;
      })
    end
  endtask

endclass

`endif

`ifndef __GUARD_UART_TRANSACTIONS_CG_SV__
`define __GUARD_UART_TRANSACTIONS_CG_SV__

// Coverage group for UART transactions
covergroup uart_transactions_cg with function sample(
  input bit       direction,
  input bit [7:0] data,
  input int       baud_rate,
  input bit       parity_enable,
  input bit       parity_type,
  input bit       second_stop_bit
);

  // Coverpoint for direction (transmit/receive)
  direction_cp : coverpoint direction {
    bins tx = {1};
    bins rx = {0};
  }

  // Coverpoint for transmitted/received data
  data_cp : coverpoint data {
    bins all_0s = {'h00};
    bins mixed  = {['h01 : 'h7F ]};
    bins all_1s = {'hff};
  }

  // Coverpoint for baud rate settings
  baud_rate_cp : coverpoint baud_rate {
    bins baud_rate_slow = {9600, 19200};
    bins baud_rate_mid  = {38400, 57600, 115200};
    bins baud_rate_sim  = {6250000};
  }

  // Coverpoint for parity enable
  parity_enable_cp : coverpoint parity_enable {
    bins enabled = {1};
    bins disabled = {0};
  }

  // Coverpoint for parity type
  parity_type_cp : coverpoint parity_type {
    bins even = {0};
    bins odd  = {1};
  }

  // Coverpoint for second stop bit
  second_stop_bit_cp : coverpoint second_stop_bit {
    bins one_stop_bit = {0};
    bins two_stop_bits = {1};
  }

  // cross coverage between direction and data
  direction_data_cross : cross direction_cp, data_cp;
  direction_baud_rate_cross : cross direction_cp, baud_rate_cp;
  direction_parity_enable_cross : cross direction_cp, parity_enable_cp;
  direction_parity_type_cross : cross direction_cp, parity_type_cp;
  direction_second_stop_bit_cross : cross direction_cp, second_stop_bit_cp;

endgroup

`endif

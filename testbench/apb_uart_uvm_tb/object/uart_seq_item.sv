`ifndef __GUARD_UART_SEQ_ITEM_SV__
`define __GUARD_UART_SEQ_ITEM_SV__ 0

// One UART frame: data byte plus the line settings used to send it
class uart_seq_item extends uvm_sequence_item;

  rand logic [7:0] data;         // data byte
  rand int         baud_rate;    // bits per second
  rand bit         parity_en;    // 1 = parity bit is used
  rand bit         parity_type;  // parity kind (even/odd, as defined by your DUT)
  rand bit         extra_stop;   // 1 = extra stop bit
  rand int         data_bits;    // number of data bits (5 to 8)

  `uvm_object_utils_begin(uart_seq_item)
    `uvm_field_int(data,        UVM_ALL_ON)
    `uvm_field_int(baud_rate,   UVM_ALL_ON)
    `uvm_field_int(parity_en,   UVM_ALL_ON)
    `uvm_field_int(parity_type, UVM_ALL_ON)
    `uvm_field_int(extra_stop,  UVM_ALL_ON)
    `uvm_field_int(data_bits,   UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name = "uart_seq_item");
    super.new(name);
  endfunction

  // Supported baud rates (soft: a test can override it)
  constraint baud_rate_c {
    soft baud_rate inside {9600, 19200, 38400, 57600, 115200, 2000000, 8000000};
  }

  // Data bits must be 5 to 8, 8 by default (soft: a test can override it)
  constraint data_bits_c {
    data_bits inside {5, 6, 7, 8};
  }

  virtual function automatic string to_string();
    return $sformatf(
      "data=0x%02h baud_rate=%-7d parity_en=%0b parity_type=%0b extra_stop=%0b data_bits=%0d",
      data,
      baud_rate,
      parity_en,
      parity_type,
      extra_stop,
      data_bits
    );
  endfunction

  virtual function automatic void display();
    $display("%s", to_string());
  endfunction

endclass

`endif

`ifndef UART_SEQ_ITEM_SV
`define UART_SEQ_ITEM_SV

class uart_seq_item extends uvm_sequence_item;

  // Frame payload
  rand bit          [7:0] data;

  // Configuration parameters matching uart_if
  rand int unsigned       baud_rate;
  rand bit                parity_en;
  rand bit                parity_type;  // 0: even, 1: odd
  rand bit                extra_stop;  // 0: 1 stop bit, 1: 2 stop bits
  rand int unsigned       data_bits;  // 5, 6, 7, or 8 bits

  // Constraints
  constraint c_default_config {
    soft baud_rate == 9600;
    soft parity_en == 1'b0;
    soft parity_type == 1'b0;
    soft extra_stop == 1'b0;
    soft data_bits == 8;
  }

  constraint c_data_bits_valid {data_bits inside {5, 6, 7, 8};}

  constraint c_data_mask {
    (data_bits == 5) -> data[7:5] == 3'b000;
    (data_bits == 6) -> data[7:6] == 2'b00;
    (data_bits == 7) -> data[7] == 1'b0;
  }

  `uvm_object_utils_begin(uart_seq_item)
    `uvm_field_int(data, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(baud_rate, UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(parity_en, UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(parity_type, UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(extra_stop, UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(data_bits, UVM_ALL_ON | UVM_DEC)
  `uvm_object_utils_end

  function new(string name = "uart_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf(
        "data=0x%02h data_bits=%0d baud_rate=%0d parity_en=%0b parity_type=%0b extra_stop=%0b",
        data,
        data_bits,
        baud_rate,
        parity_en,
        parity_type,
        extra_stop
    );
  endfunction

endclass : uart_seq_item

`endif  // UART_SEQ_ITEM_SV

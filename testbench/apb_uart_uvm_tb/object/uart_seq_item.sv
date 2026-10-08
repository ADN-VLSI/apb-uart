`ifndef __GUARD_UART_SEQ_ITEM_SV__
`define __GUARD_UART_SEQ_ITEM_SV__ 0

class uart_seq_item extends uvm_sequence_item;

  ///////////////////////////////////////////////////////////////
  // UART Data
  ///////////////////////////////////////////////////////////////
  rand bit [7:0] data;

  ///////////////////////////////////////////////////////////////
  // UART Configuration
  ///////////////////////////////////////////////////////////////
  rand bit [1:0] data_bits;
  rand bit       parity_en;
  rand bit       parity_type;
  rand bit       stop_bits;

  // 0 = RX  : drive UART_RX
  // 1 = TX  : expected/observed UART_TX
  rand bit       direction;        

  ///////////////////////////////////////////////////////////////
  // Optional error injection
  ///////////////////////////////////////////////////////////////
  rand bit       inject_parity_error;
  rand bit       inject_frame_error;

  ///////////////////////////////////////////////////////////////
  // Constructor
  ///////////////////////////////////////////////////////////////
  function new(string name = "uart_seq_item");
    super.new(name);
  endfunction

  ///////////////////////////////////////////////////////////////
  // UVM Field Automation
  ///////////////////////////////////////////////////////////////
  `uvm_object_utils_begin(uart_seq_item)
    `uvm_field_int(data,                UVM_ALL_ON)
    `uvm_field_int(data_bits,           UVM_ALL_ON)
    `uvm_field_int(parity_en,           UVM_ALL_ON)
    `uvm_field_int(parity_type,         UVM_ALL_ON)
    `uvm_field_int(stop_bits,            UVM_ALL_ON)
    `uvm_field_int(direction,            UVM_ALL_ON)
    `uvm_field_int(inject_parity_error,  UVM_ALL_ON)
    `uvm_field_int(inject_frame_error,   UVM_ALL_ON)
  `uvm_object_utils_end

  ///////////////////////////////////////////////////////////////
  // Constraints
  ///////////////////////////////////////////////////////////////

  // DUT supports:
  // depending on register encoding.
  constraint data_bits_c {
    data_bits inside {2'b00, 2'b01, 2'b10, 2'b11};
  }

  // Error injection is only meaningful for RX stimulus
  constraint error_injection_c {
    if (direction == 1'b1) {
      inject_parity_error == 1'b0;
      inject_frame_error  == 1'b0;
    }
  }

  ///////////////////////////////////////////////////////////////
  // Convert to string
  ///////////////////////////////////////////////////////////////
  function string convert2string();
    return $sformatf(
      "UART_REQ: data=0x%02h data_bits=%0d parity_en=%0d parity_type=%0d stop_bits=%0d direction=%s parity_err=%0d frame_err=%0d",
      data,
      data_bits,
      parity_en,
      parity_type,
      stop_bits,
      direction ? "TX" : "RX",
      inject_parity_error,
      inject_frame_error
    );
  endfunction

endclass

`endif
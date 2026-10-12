`ifndef __GUARD_UART_RSP_ITEM_SV__
`define __GUARD_UART_RSP_ITEM_SV__ 0

`include "testbench/apb_uart_uvm_tb/object/uart_seq_item.sv"

// Response item seen by the UART monitor.
// Inherits data, baud_rate, parity_en, parity_type, extra_stop and data_bits
// from uart_seq_item and adds the parity bit that was received.
class uart_resp_item extends uart_seq_item;

  bit parity;  // parity bit seen on the line

  `uvm_object_utils_begin(uart_resp_item)
    `uvm_field_int(data,        UVM_ALL_ON)
    `uvm_field_int(baud_rate,   UVM_ALL_ON)
    `uvm_field_int(parity_en,   UVM_ALL_ON)
    `uvm_field_int(parity_type, UVM_ALL_ON)
    `uvm_field_int(extra_stop,  UVM_ALL_ON)
    `uvm_field_int(data_bits,   UVM_ALL_ON)
    `uvm_field_int(parity,      UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name = "uart_resp_item");
    super.new(name);
  endfunction

  // Same text as the parent, plus the parity bit
  virtual function automatic string to_string();
    return $sformatf("%s parity=%0b", super.to_string(), parity);
  endfunction

endclass

`endif

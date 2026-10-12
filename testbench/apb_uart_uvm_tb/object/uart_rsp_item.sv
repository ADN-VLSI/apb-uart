`ifndef __GUARD_UART_RSP_ITEM_SV__
`define __GUARD_UART_RSP_ITEM_SV__ 0

`include "apb_uart_uvm_tb/object/uart_seq_item.sv"

class uart_rsp_item extends uart_seq_item;

  // UART Response Fields
  bit parity;

  // UVM Factory Registration
  `uvm_object_utils_begin(uart_rsp_item)
    `uvm_field_int(data,        UVM_ALL_ON)
    `uvm_field_int(baud_rate,   UVM_ALL_ON)
    `uvm_field_int(parity_en,   UVM_ALL_ON)
    `uvm_field_int(parity_type, UVM_ALL_ON)
    `uvm_field_int(extra_stop,  UVM_ALL_ON)
    `uvm_field_int(data_bits,   UVM_ALL_ON)
    `uvm_field_int(parity,      UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "uart_rsp_item");
    super.new(name);
  endfunction

  // Utility Methods
  virtual function automatic string to_string();
    return $sformatf(
      "%s parity=%0b",
      super.to_string(),
      parity
    );
  endfunction

  virtual function automatic void display();
    $display("%s", to_string());
  endfunction

endclass

`endif
`ifndef __GUARD_APB_RSP_ITEM_SV__
`define __GUARD_APB_RSP_ITEM_SV__ 0

`include "uart_regif_pkg.sv"
`include "testbench/apb_uart_uvm_tb/object/apb_seq_item.sv"

// Response item seen by the APB monitor.
// Inherits we, addr and data from apb_seq_item and adds the slave error flag.
class apb_resp_item extends apb_seq_item;

  logic slverr;  // 1 = slave reported an error for this transfer

  `uvm_object_utils_begin (apb_resp_item)
    `uvm_field_int(we,     UVM_ALL_ON)
    `uvm_field_int(addr,   UVM_ALL_ON)
    `uvm_field_int(data,   UVM_ALL_ON)
    `uvm_field_int(slverr, UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name = "apb_resp_item");
    super.new(name);
  endfunction

  // Same text as the parent, plus the slave error flag
  virtual function string to_string();
    return $sformatf("%s slverr=%0b", super.to_string(), slverr);
  endfunction

endclass

`endif

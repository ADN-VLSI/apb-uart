`ifndef __GUARD_APB_RSP_ITEM_SV__
`define __GUARD_APB_RSP_ITEM_SV__ 0

`include "apb_uart_uvm_tb/object/apb_seq_item.sv"

class apb_rsp_item extends apb_seq_item;

  // ------------------------------------------------------------
  // APB Response Fields
  // ------------------------------------------------------------

  logic slverr;

  // ------------------------------------------------------------
  // UVM Factory Registration
  // ------------------------------------------------------------

  `uvm_object_utils_begin(apb_rsp_item)
    `uvm_field_int(we,     UVM_ALL_ON)
    `uvm_field_int(addr,   UVM_ALL_ON)
    `uvm_field_int(data,   UVM_ALL_ON)
    `uvm_field_int(slverr, UVM_ALL_ON)
  `uvm_object_utils_end

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(string name = "apb_rsp_item");
    super.new(name);
  endfunction

  // ------------------------------------------------------------
  // Utility Methods
  // ------------------------------------------------------------

  virtual function automatic string to_string();
    return $sformatf(
      "%s slverr=%0b",
      super.to_string(),
      slverr
    );
  endfunction

  virtual function automatic void display();
    $display("%s", to_string());
  endfunction

endclass

`endif
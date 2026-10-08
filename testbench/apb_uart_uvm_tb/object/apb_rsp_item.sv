`ifndef __GUARD_APB_RSP_ITEM_SV__
`define __GUARD_APB_RSP_ITEM_SV__ 0

class apb_rsp_item extends uvm_sequence_item;

  // ------------------------------------------------------------
  // APB Response
  // ------------------------------------------------------------
  bit [31:0] prdata;
  bit        pready;
  bit        pslverr;

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------
  function new(string name = "apb_rsp_item");
    super.new(name);
  endfunction

  // ------------------------------------------------------------
  // UVM Field Automation
  // ------------------------------------------------------------
  `uvm_object_utils_begin(apb_rsp_item)
    `uvm_field_int(prdata,  UVM_ALL_ON)
    `uvm_field_int(pready,  UVM_ALL_ON)
    `uvm_field_int(pslverr, UVM_ALL_ON)
  `uvm_object_utils_end

  // ------------------------------------------------------------
  // Convert to string
  // ------------------------------------------------------------
  function string convert2string();
    return $sformatf(
      "APB_RSP: rdata=0x%08h ready=%0d slverr=%0d",
      prdata,
      pready,
      pslverr
    );
  endfunction

endclass

`endif
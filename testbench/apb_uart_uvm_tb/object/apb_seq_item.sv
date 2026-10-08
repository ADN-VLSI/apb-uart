`ifndef __GUARD_APB_SEQ_ITEM_SV__
`define __GUARD_APB_SEQ_ITEM_SV__ 0

class apb_seq_item extends uvm_sequence_item;

  // ------------------------------------------------------------
  // APB Request
  // ------------------------------------------------------------
  rand bit [31:0] paddr;
  rand bit        pwrite;
  rand bit [31:0] pwdata;

  // Optional APB control fields
  rand bit        pprot;
  rand bit [2:0]  pstrb;

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------
  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction

  // ------------------------------------------------------------
  // UVM Field Automation
  // ------------------------------------------------------------
  `uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(paddr,  UVM_ALL_ON)
    `uvm_field_int(pwrite, UVM_ALL_ON)
    `uvm_field_int(pwdata, UVM_ALL_ON)
    `uvm_field_int(pprot,  UVM_ALL_ON)
    `uvm_field_int(pstrb,  UVM_ALL_ON)
  `uvm_object_utils_end

  // ------------------------------------------------------------
  // Constraints
  // ------------------------------------------------------------

  // APB registers are word aligned
  constraint addr_alignment_c {
    paddr[1:0] == 2'b00;
  }

  // This UART has 32-bit APB data
  constraint strobe_c {
    pstrb == 3'b111;
  }

  // ------------------------------------------------------------
  // Convert to string
  // ------------------------------------------------------------
  function string convert2string();
    return $sformatf(
      "APB_REQ: addr=0x%08h write=%0d wdata=0x%08h pprot=%0d pstrb=%03b",
      paddr,
      pwrite,
      pwdata,
      pprot,
      pstrb
    );
  endfunction

endclass

`endif
`ifndef APB_RSP_ITEM_SV
`define APB_RSP_ITEM_SV

class apb_rsp_item extends uvm_sequence_item;

  bit          [31:0] addr;
  bit                 write;
  bit          [31:0] rdata;
  bit                 slverr;
  int unsigned        wait_cycles;

  `uvm_object_utils_begin(apb_rsp_item)
    `uvm_field_int(addr, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(write, UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(rdata, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(slverr, UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(wait_cycles, UVM_ALL_ON | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "apb_rsp_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf(
        "addr=0x%08h write=%0b rdata=0x%08h slverr=%0b wait_cycles=%0d",
        addr,
        write,
        rdata,
        slverr,
        wait_cycles
    );
  endfunction

endclass : apb_rsp_item

`endif  // APB_RSP_ITEM_SV

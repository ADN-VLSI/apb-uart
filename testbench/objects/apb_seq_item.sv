`ifndef APB_SEQ_ITEM_SV
`define APB_SEQ_ITEM_SV

class apb_seq_item extends uvm_sequence_item;

  // Transaction Fields
  rand bit          [31:0] addr;
  rand bit                 write;
  rand bit          [31:0] wdata;
  rand bit          [ 3:0] strb;
  rand int unsigned        delay;

  // Constraints
  constraint c_default_strb {
    strb inside {4'b0001, 4'b0011, 4'b1111};
    soft strb == 4'b1111;
  }

  constraint c_addr_aligned {
    addr[1:0] == 2'b00;  // 32-bit word aligned
  }

  constraint c_delay {soft delay inside {[0 : 5]};}

  `uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(addr, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(write, UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(wdata, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(strb, UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(delay, UVM_ALL_ON | UVM_DEC | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf("addr=0x%08h write=%0b wdata=0x%08h strb=4'b%04b delay=%0d", addr, write,
                     wdata, strb, delay);
  endfunction

endclass : apb_seq_item

`endif  // APB_SEQ_ITEM_SV

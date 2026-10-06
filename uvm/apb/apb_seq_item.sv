// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_APB_SEQ_ITEM_SV__
`define __GUARD_APB_SEQ_ITEM_SV__ 0

// APB Sequence Item
// This class represents a sequence item for APB transactions,
// extending uvm_sequence_item to include request fields like
// transaction type, address, and data.
class apb_seq_item extends uvm_sequence_item;

  // Request fields
  rand bit tx_type;      // 0: Read, 1: Write
  rand bit [31:0] addr;  // 32-bit address
  rand bit [31:0] data;  // 32-bit write data

  // UVM object utilities for factory registration and field automation
  `uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(tx_type, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end

  constraint addr_c {
    addr inside {'h00, 'h04, 'h08, 'h10, 'h14, 'h18, 'h1C,
                 'h20, 'h24, 'h28, 'h2C, 'h30};
  }

  constraint tx_type_c {
    if (addr inside {'h08, 'h14, 'h18, 'h24, 'h28, 'h2C}) tx_type == 0;
    if (addr == 'h1C) tx_type == 1;
  }

  constraint data_c {
    if (!tx_type) data == '0;
    if (addr == 'h00) data inside {[0:31]};
    if (addr == 'h04) data inside {[0:32'h001F_FFFF]};
    if (addr == 'h1C) data inside {[0:255]};
    if (addr == 'h30) data inside {[0:15]};
  }

  // Constructor for the APB sequence item
  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction : new

endclass

`endif
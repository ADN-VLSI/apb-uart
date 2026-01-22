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

  constraint tx_type_c {
    if (addr inside {'h14}) tx_type == 1; // Write only for TX_DATA register
    if (addr inside {'h0C, 'h10, 'h18}) tx_type == 0; // Read only for RX_FIFO_COUNT, TX_FIFO_COUNT, RX_DATA registers
  }

  constraint addr_c { 
    addr % 4 == 0; // Address must be word-aligned
    addr >= 32'h0000_0000 && addr <= 32'h0000_001C; // Address range constraint
  }

  constraint data_c {
    if (tx_type == 0) data == '0; // Data is zero for read transactions
    if (addr == 'h00) data inside {[0:7]};
    if (addr == 'h08) data inside {[0:7]};
    if (addr == 'h14) data inside {[0:255]};
    if (addr == 'h1C) data inside {[0:15]};
  }

  // Constructor for the APB sequence item
  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction : new

endclass

`endif

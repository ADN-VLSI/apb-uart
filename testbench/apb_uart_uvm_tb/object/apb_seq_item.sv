`ifndef __GUARD_APB_SEQ_ITEM_SV__
`define __GUARD_APB_SEQ_ITEM_SV__ 0

`include "uvm_macros.svh"

import uvm_pkg::*;
import uart_reg_if_pkg::*;

class apb_seq_item extends uvm_sequence_item;

  // ------------------------------------------------------------
  // APB Request Fields
  // ------------------------------------------------------------

  rand logic        we;       // 0: Read, 1: Write
  rand logic [31:0] addr;     // Byte Address
  rand logic [31:0] data;     // Write data

  // ------------------------------------------------------------
  // Randomization Controls
  // ------------------------------------------------------------

  bit allow_random_addr = 0;
  bit allow_random_data = 0;

  // ------------------------------------------------------------
  // UVM Factory Registration
  // ------------------------------------------------------------

  `uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(we,                UVM_ALL_ON)
    `uvm_field_int(addr,              UVM_ALL_ON)
    `uvm_field_int(data,              UVM_ALL_ON)
    `uvm_field_int(allow_random_addr, UVM_ALL_ON)
    `uvm_field_int(allow_random_data, UVM_ALL_ON)
  `uvm_object_utils_end

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction

  // ------------------------------------------------------------
  // Address Constraints
  // ------------------------------------------------------------

  constraint addr_c {

    if (!allow_random_addr) {

      // Write transaction
      if (we) {
        addr inside {ADDR_CTRL, ADDR_CFG, ADDR_TXR, ADDR_TXD, ADDR_RXR, ADDR_INTR};
      }

      // Read transaction
      else {
        addr inside {ADDR_CTRL, ADDR_CFG , ADDR_STATUS, ADDR_TXGP, ADDR_TXG , ADDR_RXGP, ADDR_RXG , ADDR_RXD , ADDR_INTR};
      }
    }
  }

  // ------------------------------------------------------------
  // Data Constraints
  // ------------------------------------------------------------

  constraint data_c {

    if (!allow_random_data) {

      // Read transactions do not drive meaningful write data.
      if (!we) data == '0;

      // UART_CTRL: reserved bits [31:5].
      if (we && addr == (ADDR_CTRL)) data[31:5] == '0;

      // UART_CFG: reserved bits [31:21].
      if (we && addr == (ADDR_CFG)) data[31:21] == '0;

      // UART_TXR: request ID [7:0].
      if (we && addr == (ADDR_TXR)) data[31:8] == '0;

      // UART_TXD: transmit data [7:0].
      if (we && addr == (ADDR_TXD)) data[31:8] == '0;

      // UART_RXR: request ID [7:0].
      if (we && addr == (ADDR_RXR)) data[31:8] == '0;

      // UART_INTR: interrupt enables [3:0].
      if (we && addr == (ADDR_INTR)) data[31:4] == '0;
    }
  }

  // ------------------------------------------------------------
  // Post Randomization
  // ------------------------------------------------------------

  function void post_randomize();

    if (!allow_random_data) begin

      if (!we) data = '0;

      if (we && addr == (ADDR_CTRL)) data[31:5] = '0;
      if (we && addr == (ADDR_CFG)) data[31:21] = '0;
      if (we && addr == (ADDR_TXR)) data[31:8] = '0;
      if (we && addr == (ADDR_TXD)) data[31:8] = '0;
      if (we && addr == (ADDR_RXR)) data[31:8] = '0;
      if (we && addr == (ADDR_INTR)) data[31:4] = '0;

    end

  endfunction

  // ------------------------------------------------------------
  // Utility Methods
  // ------------------------------------------------------------

  virtual function automatic string to_string();
    return $sformatf(
      "we=%0b addr=0x%03h data=0x%08h",
      we,
      addr,
      data
    );
  endfunction

  virtual function automatic void display();
    $display("%s", to_string());
  endfunction

endclass

`endif
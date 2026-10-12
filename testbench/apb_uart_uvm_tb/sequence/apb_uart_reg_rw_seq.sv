`ifndef __GUARD_APB_UART_REG_RW_SEQ_SV__
`define __GUARD_APB_UART_REG_RW_SEQ_SV__ 0

`include "apb_uart_top_uvm_tb/obj/apb/apb_seq_item.sv"

// Sequence: write a random value to the CFG register, then read it back.
// The scoreboard checks that the value read matches the value written.
// How many write/read pairs: set APB_UART_REG_RW_SEQ_LENGTH in the config DB (default 1).
// Note: apb_seq_item clears the unused upper bits (31:21) of CFG when it randomizes.
class apb_uart_reg_rw_seq extends uvm_sequence #(apb_seq_item);

  `uvm_object_utils(apb_uart_reg_rw_seq)

  function new (string name = "apb_uart_reg_rw_seq");
    super.new(name);
  endfunction

  virtual task body();
    int seq_length;

    // Number of write/read pairs (use 1 if the test did not set it)
    if (!uvm_config_db#(int)::get(uvm_root::get(), "parameter", "APB_UART_REG_RW_SEQ_LENGTH", seq_length)) begin
      seq_length = 1;
    end

    repeat (seq_length) begin
      // Write a random value to CFG
      `uvm_do_with(req, {we == 1; addr == ADDR_CFG;})
      // Read CFG back
      `uvm_do_with(req, {we == 0; addr == ADDR_CFG;})
    end
  endtask

endclass

`endif

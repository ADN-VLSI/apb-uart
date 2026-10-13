`ifndef __GUARD_APB_UART_INIT_SEQ_SV__
`define __GUARD_APB_UART_INIT_SEQ_SV__ 0

`include "apb_uart_uvm_tb/object/apb_seq_item.sv"

// Sequence: set up the UART over APB before any TX or RX traffic.
// Four writes, in this order (CTRL: [4] rx_en, [3] tx_en, [2] rx_flush, [1] tx_flush, [0] sw_rst):
//   1. address 0x00 <= 0b00110       flush both FIFOs
//   2. address 0x00 <= 0b00000       release the flush
//   3. address 0x04 <= 0x0003_0364   baud divider 868, 8 data bits, no parity, 1 stop bit
//   4. address 0x00 <= 0b11000       enable the transmitter and the receiver
class apb_uart_init_seq extends uvm_sequence #(apb_seq_item);

  `uvm_object_utils(apb_uart_init_seq)

  function new (string name = "apb_uart_init_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_do_with(req, {we == 1; addr == 'h00; data == 'b00110;})
    `uvm_do_with(req, {we == 1; addr == 'h00; data == 'b00000;})
    `uvm_do_with(req, {we == 1; addr == 'h04; data == 32'h0003_0364;})
    `uvm_do_with(req, {we == 1; addr == 'h00; data == 'b11000;})
  endtask

endclass

`endif

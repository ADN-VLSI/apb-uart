`ifndef __GUARD_APB_UART_REG_ACCESS_CG_SV__
`define __GUARD_APB_UART_REG_ACCESS_CG_SV__

// Coverage group for REG ACCESS
covergroup apb_uart_reg_access_cg with function sample(
  input bit [4:0] addr,
  input bit       write
);

  // Coverpoint for 0x00 CTRL register access
  ctrl_reg_cp : coverpoint addr iff (addr == 'h00) {
    bins read  = { 'h00 } iff (write == 0);
    bins write = { 'h00 } iff (write == 1);
  }

  // Coverpoint for 0x04 CLK_DIV register access
  clk_div_reg_cp : coverpoint addr iff (addr == 'h04) {
    bins read  = { 'h04 } iff (write == 0);
    bins write = { 'h04 } iff (write == 1);
  }

  // Coverpoint for 0x08 CFG register access
  cfg_reg_cp : coverpoint addr iff (addr == 'h08) {
    bins read  = { 'h08 } iff (write == 0);
    bins write = { 'h08 } iff (write == 1);
  }

  // Coverpoint for 0x0C TX_FIFO_COUNT register access
  tx_fifo_count_reg_cp : coverpoint addr iff (addr == 'h0C) {
    bins read  = { 'h0C } iff (write == 0);
  }

  // Coverpoint for 0x10 RX_FIFO_COUNT register access
  rx_fifo_count_reg_cp : coverpoint addr iff (addr == 'h10) {
    bins read  = { 'h10 } iff (write == 0);
  }

  // Coverpoint for 0x14 TX_DATA register access
  tx_data_reg_cp : coverpoint addr iff (addr == 'h14) {
    bins write = { 'h14 } iff (write == 1);
  }

  // Coverpoint for 0x18 RX_DATA register access
  rx_data_reg_cp : coverpoint addr iff (addr == 'h18) {
    bins read  = { 'h18 } iff (write == 0);
  }

  // Coverpoint for 0x1C INTR_CTRL register access
  intr_ctrl_reg_cp : coverpoint addr iff (addr == 'h1C) {
    bins read  = { 'h1C } iff (write == 0);
    bins write = { 'h1C } iff (write == 1);
  }

endgroup

`endif

`ifndef __GUARD_UART_EN_APB_SEQ_SV__
`define __GUARD_UART_EN_APB_SEQ_SV__ 0

`include "apb_base_seq.sv"

class uart_en_apb_seq extends apb_base_seq;

  `uvm_object_utils(uart_en_apb_seq)

  function new(string name = "uart_en_apb_seq");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_info(get_type_name(), "Configuring and enabling UART", UVM_LOW)

    // ----------------------------------------------------------
    // Configure UART
    // ----------------------------------------------------------

    // 8 data bits, parity disabled, one stop bit.
    // Prescaler = 4, clk_div = 0x05B.
    apb_write(ADDR_CFG, 32'h0003_405B);

    // ----------------------------------------------------------
    // Configure Arbitration Request IDs
    // ----------------------------------------------------------

    // The RTL currently uses grant ID 1.
    apb_write(ADDR_TXR, 32'h0000_0001);
    apb_write(ADDR_RXR, 32'h0000_0001);

    // ----------------------------------------------------------
    // Enable UART
    // ----------------------------------------------------------

    // UART_CTRL:
    // bit 4 = rx_en
    // bit 3 = tx_en
    // bit 2 = rx_flush
    // bit 1 = tx_flush
    // bit 0 = sw_rst
    //
    // 0x18 enables RX and TX.
    apb_write(ADDR_CTRL, 32'h0000_0018);

    `uvm_info(get_type_name(), "UART configuration completed", UVM_LOW)

  endtask : body

endclass

`endif
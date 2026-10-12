`ifndef __GUARD_ALL_REG_ACCESS_SEQ_SV__
`define __GUARD_ALL_REG_ACCESS_SEQ_SV__ 0

`include "apb_base_seq.sv"

class all_reg_access_seq extends apb_base_seq;

  `uvm_object_utils(all_reg_access_seq)

  function new(string name = "all_reg_access_seq");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_info(get_type_name(), "Starting all register access sequence", UVM_LOW)

    // ----------------------------------------------------------
    // Writable Registers
    // ----------------------------------------------------------

    // Configure UART: 8 data bits, no parity, one stop bit,
    // using the CFG register's reset-value configuration.
    apb_write(ADDR_CFG, 32'h0003_405B);

    // Request IDs used by the arbitration interface.
    apb_write(ADDR_TXR, 32'h0000_0001);
    apb_write(ADDR_RXR, 32'h0000_0001);

    // Write transmit data.
    apb_write(ADDR_TXD, 32'h0000_005A);

    // Enable TX and RX.
    apb_write(ADDR_CTRL, 32'h0000_0018);

    // Configure all four interrupt enables.
    apb_write(ADDR_INTR, 32'h0000_000F);

    // ----------------------------------------------------------
    // Readable Registers
    // ----------------------------------------------------------

    apb_read(ADDR_CTRL);
    apb_read(ADDR_CFG);
    apb_read(ADDR_STATUS);

    apb_read(ADDR_TXGP);
    apb_read(ADDR_TXG);

    apb_read(ADDR_RXGP);
    apb_read(ADDR_RXG);

    apb_read(ADDR_INTR);

    // RXD is meaningful only when received data is available.
    // Read it only after arranging for a valid RX transaction.
    `uvm_info(get_type_name(), "Completed register access sequence", UVM_LOW)

  endtask : body

endclass

`endif
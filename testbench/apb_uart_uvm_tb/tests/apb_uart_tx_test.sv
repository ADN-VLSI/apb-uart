`ifndef __GUARD_APB_UART_TX_TEST_SV__
`define __GUARD_APB_UART_TX_TEST_SV__ 0

`include "apb_uart_uvm_tb/tests/apb_uart_base_test.sv"
`include "apb_uart_uvm_tb/sequence/apb_uart_init_seq.sv"
`include "apb_uart_uvm_tb/sequence/random_apb_wdata_seq.sv"

// TX test: the CPU writes random bytes to TXD over APB,
// and the scoreboard checks that the same bytes appear on the UART TX line.
class apb_uart_tx_test extends apb_uart_base_test;

  `uvm_component_utils(apb_uart_tx_test)

  function new (string name = "apb_uart_tx_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task main_phase(uvm_phase phase);
    apb_uart_init_seq    init_seq;
    random_apb_wdata_seq wr_seq;

    super.main_phase(phase);
    phase.raise_objection(this);

    // Number of bytes to send (read by random_apb_wdata_seq)
    uvm_config_db#(int)::set(uvm_root::get(), "parameter", "RANDOM_APB_WDATA_SEQ_LENGTH", 10);

    init_seq = apb_uart_init_seq::type_id::create("init_seq");
    wr_seq   = random_apb_wdata_seq::type_id::create("wr_seq");

    // 1. Set up the UART
    init_seq.start(env.apb.sqr);

    // 2. Write the random bytes to TXD
    wr_seq.start(env.apb.sqr);

    phase.drop_objection(this);
  endtask

endclass

`endif

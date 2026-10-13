`ifndef __GUARD_APB_UART_RX_TEST_SV__
`define __GUARD_APB_UART_RX_TEST_SV__ 0

`include "apb_uart_uvm_tb/tests/apb_uart_base_test.sv"
`include "apb_uart_uvm_tb/sequence/apb_uart_init_seq.sv"
`include "apb_uart_uvm_tb/sequence/random_uart_rx_seq.sv"
`include "apb_uart_uvm_tb/sequence/random_apb_rdata_seq.sv"

// RX test: random bytes are sent into the DUT on the UART RX line,
// then the CPU reads them back from RXD over APB.
// The scoreboard checks that every byte read matches the byte that was sent.
class apb_uart_rx_test extends apb_uart_base_test;

  `uvm_component_utils(apb_uart_rx_test)

  function new (string name = "apb_uart_rx_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task main_phase(uvm_phase phase);
    apb_uart_init_seq     init_seq;
    random_uart_rx_seq    rx_seq;
    random_apb_rdata_seq  rd_seq;

    super.main_phase(phase);
    phase.raise_objection(this);

    // Send N bytes on RX, then read N bytes from RXD (keep the two numbers equal)
    uvm_config_db#(int)::set(uvm_root::get(), "parameter", "RANDOM_UART_RX_SEQ_LENGTH",   4);
    uvm_config_db#(int)::set(uvm_root::get(), "parameter", "RANDOM_APB_RDATA_SEQ_LENGTH", 4);

    init_seq = apb_uart_init_seq::type_id::create("init_seq");
    rx_seq   = random_uart_rx_seq::type_id::create("rx_seq");
    rd_seq   = random_apb_rdata_seq::type_id::create("rd_seq");

    // 1. Set up the UART
    init_seq.start(env.apb.sqr);

    // 2. Send the random bytes into the DUT on the RX line
    rx_seq.start(env.rx.sqr);

    // 3. Read the bytes back from RXD
    rd_seq.start(env.apb.sqr);

    phase.drop_objection(this);
  endtask

endclass

`endif

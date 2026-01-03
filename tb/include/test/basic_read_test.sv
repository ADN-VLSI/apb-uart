`ifndef __GUARD_BASIC_READ_TEST_SV__
`define __GUARD_BASIC_READ_TEST_SV__ 0

`include "test/base_test.sv"
`include "sequence/random_apb_rdata_seq.sv"
`include "sequence/random_uart_rx_seq.sv"

// -----------------------------------------------------------------------------
// Test: basic_read_test
//
// Intent
//  - Drive randomized UART RX traffic into the DUT.
//  - Then perform randomized APB reads to pull received data/status back out.
//
// Notes
//  - Sequence lengths are configured via uvm_config_db under the "parameter"
//    scope, which is the convention used by this testbench.
//  - After starting a sequence, we wait for both APB and UART interfaces to be
//    idle to ensure all bus activity has completed before moving on.
// -----------------------------------------------------------------------------
class basic_read_test extends base_test;

  `uvm_component_utils(basic_read_test)
  function new(string name = "basic_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  task main_phase(uvm_phase phase);
    // Hold the phase open until stimulus + drains complete.
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Basic read test started", UVM_LOW)

    begin  // SEND RX
      // Drive randomized UART RX into the DUT.
      // The sequence reads its transaction count from config DB.
      random_uart_rx_seq my_seq;
      uvm_config_db#(int)::set(uvm_root::get(), "parameter", "RANDOM_UART_RX_SEQ_LENGTH", 256);
      my_seq = random_uart_rx_seq::type_id::create("my_seq");
      my_seq.start(env.uart.seqr);
    end
    fork
      // Ensure all UART/APB activity has settled before starting the next step.
      // Waiting on both interfaces avoids races with scoreboard/monitors.
      apb_intf.wait_till_idle();
      uart_intf.wait_till_idle();
    join

    begin  // RECV APB
      // Perform randomized APB reads (e.g., RX FIFO/data/status) after UART RX.
      // The sequence reads its transaction count from config DB.
      random_apb_rdata_seq my_seq;
      uvm_config_db#(int)::set(uvm_root::get(), "parameter", "RANDOM_APB_RDATA_SEQ_LENGTH", 256);
      my_seq = random_apb_rdata_seq::type_id::create("my_seq");
      my_seq.start(env.apb.seqr);
    end
    fork
      // Drain any trailing bus activity before ending the test.
      apb_intf.wait_till_idle();
      uart_intf.wait_till_idle();
    join

    `uvm_info(get_type_name(), "Basic read test completed", UVM_LOW)
    // Allow the phase to complete.
    phase.drop_objection(this);
  endtask : main_phase

endclass : basic_read_test
`endif

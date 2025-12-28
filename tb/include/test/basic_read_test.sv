`ifndef __GUARD_BASIC_READ_TEST_SV__
`define __GUARD_BASIC_READ_TEST_SV__ 0

`include "test/base_test.sv"
`include "sequence/random_apb_rdata_seq.sv"
`include "sequence/random_uart_rx_seq.sv"

class basic_read_test extends base_test;

  `uvm_component_utils(basic_read_test)
  function new(string name = "basic_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Basic read test started", UVM_LOW)

    begin  // SEND RX
      random_uart_rx_seq my_seq;
      uvm_config_db#(int)::set(uvm_root::get(), "parameter", "RANDOM_UART_RX_SEQ_LENGTH", 256);
      my_seq = random_uart_rx_seq::type_id::create("my_seq");
      my_seq.start(env.uart.seqr);
    end
    fork
      apb_intf.wait_till_idle();
      uart_intf.wait_till_idle();
    join

    begin  // RECV APB
      random_apb_rdata_seq my_seq;
      uvm_config_db#(int)::set(uvm_root::get(), "parameter", "RANDOM_APB_RDATA_SEQ_LENGTH", 256);
      my_seq = random_apb_rdata_seq::type_id::create("my_seq");
      my_seq.start(env.apb.seqr);
    end
    fork
      apb_intf.wait_till_idle();
      uart_intf.wait_till_idle();
    join

    `uvm_info(get_type_name(), "Basic read test completed", UVM_LOW)
    phase.drop_objection(this);
  endtask : main_phase

endclass : basic_read_test
`endif

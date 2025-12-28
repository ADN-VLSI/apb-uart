`ifndef __GUARD_BASIC_WRITE_TEST_SV__
`define __GUARD_BASIC_WRITE_TEST_SV__ 0

`include "test/base_test.sv"
`include "sequence/random_apb_wdata_seq.sv"

class basic_write_test extends base_test;

  `uvm_component_utils(basic_write_test)
  function new(string name = "basic_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Basic write test started", UVM_LOW)

    begin  // SEND APB
      random_apb_wdata_seq my_seq;
      uvm_config_db#(int)::set(uvm_root::get(), "parameter", "RANDOM_APB_WDATA_SEQ_LENGTH", 256);
      my_seq = random_apb_wdata_seq::type_id::create("my_seq");
      my_seq.start(env.apb.seqr);
    end
    fork
      apb_intf.wait_till_idle();
      uart_intf.wait_till_idle();
    join

    `uvm_info(get_type_name(), "Basic write test completed", UVM_LOW)
    phase.drop_objection(this);
  endtask : main_phase

endclass : basic_write_test

`endif

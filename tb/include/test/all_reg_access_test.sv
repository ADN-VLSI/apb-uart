// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_ALL_REG_ACCESS_TEST_SV__
`define __GUARD_ALL_REG_ACCESS_TEST_SV__ 0

// Include base test and sequence classes
`include "test/base_test.sv"
`include "sequence/all_reg_access_seq.sv"

// All Register Access Test
// This test performs APB register accesses to configure the UART.
class all_reg_access_test extends base_test;

  // UVM component utilities for factory registration
  `uvm_component_utils(all_reg_access_test)

  // Constructor for the basic write test
  function new(string name = "all_reg_access_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Main phase: execute APB write sequence
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "All register access test started", UVM_LOW)

    begin  // SEND APB
      // Perform randomized APB writes to UART TX
      all_reg_access_seq my_seq;
      uvm_config_db#(int)::set(uvm_root::get(), "parameter", "RANDOM_ACCESS_LEN", 256);
      my_seq = all_reg_access_seq::type_id::create("my_seq");
      my_seq.start(env.apb.seqr);
    end
    fork
      // Wait for interfaces to be idle
      apb_intf.wait_till_idle();
      uart_intf.wait_till_idle();
    join

    `uvm_info(get_type_name(), "All register access test completed", UVM_LOW)
    phase.drop_objection(this);
  endtask : main_phase

endclass : all_reg_access_test

`endif

// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_ALL_REG_ACCESS_TEST_SV__
`define __GUARD_ALL_REG_ACCESS_TEST_SV__ 0

// Include base test and sequence classes
`include "tests/base_test.sv"

// All Register Access Test
// This test performs APB register accesses to configure the UART.
class all_reg_access_test extends base_test;

  // UVM component utilities for factory registration
  `uvm_component_utils(all_reg_access_test)

  // Constructor for the basic write test
  function new(string name = "all_reg_access_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function int get_test_id();
    return 2;
  endfunction

endclass : all_reg_access_test

`endif
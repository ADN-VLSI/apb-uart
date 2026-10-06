// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_BASIC_WRITE_TEST_SV__
`define __GUARD_BASIC_WRITE_TEST_SV__ 0

// Include base test and sequence classes
`include "tests/base_test.sv"

// Basic Write Test
// This test performs randomized APB writes to send data to the UART TX.
// It configures the sequence length and waits for interfaces to be idle.
class basic_write_test extends base_test;

  // UVM component utilities for factory registration
  `uvm_component_utils(basic_write_test)

  // Constructor for the basic write test
  function new(string name = "basic_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function int get_test_id();
    return 1;
  endfunction

endclass : basic_write_test

`endif
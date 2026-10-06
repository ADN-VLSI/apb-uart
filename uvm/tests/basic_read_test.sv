// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_BASIC_READ_TEST_SV__
`define __GUARD_BASIC_READ_TEST_SV__ 0

// Include base test and sequence classes
`include "tests/base_test.sv"

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

  // UVM component utilities for factory registration
  `uvm_component_utils(basic_read_test)

  // Constructor for the basic read test
  function new(string name = "basic_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function int get_test_id();
    return 0;
  endfunction

endclass : basic_read_test

`endif
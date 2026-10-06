// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_BASE_TEST_SV__
`define __GUARD_BASE_TEST_SV__ 0

`include "env/apb_uart_env.sv"
`include "sequence/apb_reg_seq.sv"

// Base Test
// This is the base UVM test class that sets up the test environment,
// applies reset, configures the DUT, and provides a framework for derived tests.
class base_test extends uvm_test;

  // UVM component utilities for factory registration
  `uvm_component_utils(base_test)

  apb_uart_env env;

  // Constructor for the base test
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase: create the test environment
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_uart_env::type_id::create("env", this);
  endfunction

  virtual function int get_test_id();
    return 0;
  endfunction

  virtual task main_phase(uvm_phase phase);
    apb_reg_seq seq;
    phase.raise_objection(this);
    seq = apb_reg_seq::type_id::create("seq");
    seq.test_id = get_test_id();
    seq.start(env.apb.seqr);
    phase.drop_objection(this);
  endtask : main_phase

  virtual function void report_phase(uvm_phase phase);
    if (uvm_report_server::get_server().get_severity_count(UVM_ERROR) == 0 &&
        uvm_report_server::get_server().get_severity_count(UVM_FATAL) == 0) begin
      $display("TEST PASSED");
    end else begin
      $display("TEST FAILED");
    end
  endfunction : report_phase

endclass : base_test

`endif
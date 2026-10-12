`ifndef __GUARD_BASIC_READ_TEST_SV__
`define __GUARD_BASIC_READ_TEST_SV__ 0

`include "uvm_macros.svh"
`include "base_test.sv"

class basic_read_test extends base_test;

  // ------------------------------------------------------------
  // UVM Registration
  // ------------------------------------------------------------

  `uvm_component_utils(basic_read_test)

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(
    string name = "basic_read_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction : new

  // ------------------------------------------------------------
  // Run Phase
  // ------------------------------------------------------------

  virtual task run_phase(uvm_phase phase);

    random_apb_rdata_seq read_seq;

    phase.raise_objection(this);

    `uvm_info(
      get_type_name(),
      "Starting basic APB read test",
      UVM_LOW
    )

    // Wait for reset to be released.
    wait (env.apb_agent.vif.PRESETn === 1'b1);

    // Allow the DUT to settle after reset.
    repeat (2) @(posedge env.apb_agent.vif.PCLK);

    read_seq = random_apb_rdata_seq::type_id::create(
      "read_seq"
    );

    read_seq.start(env.apb_agent.sequencer);

    `uvm_info(
      get_type_name(),
      "Basic APB read test completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask : run_phase

endclass : basic_read_test

`endif
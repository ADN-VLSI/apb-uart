`ifndef __GUARD_BASIC_WRITE_TEST_SV__
`define __GUARD_BASIC_WRITE_TEST_SV__ 0

`include "uvm_macros.svh"
`include "base_test.sv"
`include "sequence/random_apb_wdata_seq.sv"

class basic_write_test extends base_test;

  // ------------------------------------------------------------
  // UVM Registration
  // ------------------------------------------------------------

  `uvm_component_utils(basic_write_test)

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(
    string name = "basic_write_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction : new

  // ------------------------------------------------------------
  // Run Phase
  // ------------------------------------------------------------

  virtual task run_phase(uvm_phase phase);

    random_apb_wdata_seq write_seq;

    phase.raise_objection(this);

    `uvm_info(
      get_type_name(),
      "Starting basic APB write test",
      UVM_LOW
    )

    // Wait for reset to be released.
    wait (env.apb_agent_inst.vif.PRESETn === 1'b1);

    // Allow the DUT to settle after reset.
    repeat (2) @(posedge env.apb_agent_inst.vif.PCLK);

    write_seq = random_apb_wdata_seq::type_id::create(
      "write_seq"
    );

    write_seq.start(env.apb_agent_inst.sequencer);

    `uvm_info(
      get_type_name(),
      "Basic APB write test completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask : run_phase

endclass : basic_write_test

`endif
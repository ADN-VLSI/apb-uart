`ifndef __GUARD_ALL_REG_ACCESS_TEST_SV__
`define __GUARD_ALL_REG_ACCESS_TEST_SV__ 0

`include "uvm_macros.svh"
`include "base_test.sv"

class all_reg_access_test extends base_test;

  // ------------------------------------------------------------
  // UVM Registration
  // ------------------------------------------------------------

  `uvm_component_utils(all_reg_access_test)

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(
    string name = "all_reg_access_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction : new

  // ------------------------------------------------------------
  // Run Phase
  // ------------------------------------------------------------

  virtual task run_phase(uvm_phase phase);

    all_reg_access_seq reg_seq;

    phase.raise_objection(this);

    `uvm_info(
      get_type_name(),
      "Starting all-register-access test",
      UVM_LOW
    )

    // Wait for reset to be released.
    wait (env.apb_agent.vif.PRESETn === 1'b1);

    // Allow the DUT to settle after reset.
    repeat (2) @(posedge env.apb_agent.vif.PCLK);

    reg_seq = all_reg_access_seq::type_id::create(
      "reg_seq"
    );

    reg_seq.start(env.apb_agent.sequencer);

    `uvm_info(
      get_type_name(),
      "All-register-access test completed",
      UVM_LOW
    )

    phase.drop_objection(this);

  endtask : run_phase

endclass : all_reg_access_test

`endif
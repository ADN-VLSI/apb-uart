`ifndef __GUARD_BASE_TEST_SV__
`define __GUARD_BASE_TEST_SV__ 0

`include "uvm_macros.svh"

class base_test extends uvm_test;

  // ------------------------------------------------------------
  // UVM Registration
  // ------------------------------------------------------------

  `uvm_component_utils(base_test)

  // ------------------------------------------------------------
  // Environment
  // ------------------------------------------------------------

  apb_uart_env env;

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(
    string name = "base_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction : new

  // ------------------------------------------------------------
  // Build Phase
  // ------------------------------------------------------------

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env = apb_uart_env::type_id::create(
      "env",
      this
    );

  endfunction : build_phase

  // ------------------------------------------------------------
  // End of Elaboration Phase
  // ------------------------------------------------------------

  virtual function void end_of_elaboration_phase(
    uvm_phase phase
  );

    super.end_of_elaboration_phase(phase);

    `uvm_info(
      get_type_name(),
      "APB UART UVM environment constructed",
      UVM_LOW
    )

    // Print component hierarchy for debugging.
    uvm_top.print_topology();

  endfunction : end_of_elaboration_phase

  // ------------------------------------------------------------
  // Report Phase
  // ------------------------------------------------------------

  virtual function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info(
      get_type_name(),
      "APB UART test completed",
      UVM_LOW
    )

  endfunction : report_phase

endclass : base_test

`endif
`ifndef __GUARD_APB_UART_BASE_TEST_SV__
`define __GUARD_APB_UART_BASE_TEST_SV__ 0

`include "apb_uart_top_uvm_tb/cmp/apb_uart_env.sv"

// Base test: builds the env, finds the virtual interfaces, and handles
// reset, clock start and "wait until idle" at the end.
// Other tests extend this one and only add their own sequences.
class apb_uart_base_test extends uvm_test;

  `uvm_component_utils(apb_uart_base_test)

  apb_uart_env env;

  // Virtual interfaces (set by the top module)
  virtual ctrl_if ctrl_intf;  // clock and reset control
  virtual apb_if  apb_intf;
  virtual uart_if tx_intf;
  virtual uart_if rx_intf;

  function new (string name = "apb_uart_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_uart_env::type_id::create("env", this);
  endfunction

  // Get all four virtual interfaces from the config DB
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (!uvm_config_db#(virtual ctrl_if)::get(uvm_root::get(), "*.env.ctrl.*", "intf", ctrl_intf)) begin
      `uvm_fatal("NOVIF", "ctrl_if virtual interface not found")
    end
    if (!uvm_config_db#(virtual apb_if)::get(uvm_root::get(), "*.env.apb.*", "intf", apb_intf)) begin
      `uvm_fatal("NOVIF", "apb_if virtual interface not found")
    end
    if (!uvm_config_db#(virtual uart_if)::get(uvm_root::get(), "*.env.tx.*", "intf", tx_intf)) begin
      `uvm_fatal("NOVIF", "uart_if (tx) virtual interface not found")
    end
    if (!uvm_config_db#(virtual uart_if)::get(uvm_root::get(), "*.env.rx.*", "intf", rx_intf)) begin
      `uvm_fatal("NOVIF", "uart_if (rx) virtual interface not found")
    end
  endfunction

  // Print the testbench structure once it is built
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  // Reset all interfaces
  virtual task reset_phase(uvm_phase phase);
    super.reset_phase(phase);
    phase.raise_objection(this);
    apb_intf.apply_reset();
    tx_intf.apply_reset();
    rx_intf.apply_reset();
    ctrl_intf.apply_reset();
    phase.drop_objection(this);
  endtask

  // Start the clock
  virtual task configure_phase(uvm_phase phase);
    super.configure_phase(phase);
    phase.raise_objection(this);
    ctrl_intf.start_clock();
    phase.drop_objection(this);
  endtask

  // At the end, wait until every interface is idle
  virtual task shutdown_phase(uvm_phase phase);
    super.shutdown_phase(phase);
    phase.raise_objection(this);
    fork
      apb_intf.wait_till_idle();
      tx_intf.wait_till_idle();
      rx_intf.wait_till_idle();
    join
    phase.drop_objection(this);
  endtask

endclass

`endif

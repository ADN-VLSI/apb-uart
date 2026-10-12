`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

// The interfaces (apb_if, uart_if, ctrl_if) and the DUT must be compiled before this file.
`include "uart_regif_pkg.sv"

// Same APB struct types as the DUT (apb_req_t / apb_resp_t).
// If your tool says they are already defined (DUT and testbench share one
// compilation unit), delete these two lines.
`include "../submodule/adn_apb/include/apb/typedef.svh"
`APB_T(apb, 32, 32)

// Tests (each one pulls in the base test, env, agents and sequences it needs)
`include "apb_uart_top_uvm_tb/tests/apb_uart_tx_test.sv"
`include "apb_uart_top_uvm_tb/tests/apb_uart_rx_test.sv"
`include "apb_uart_top_uvm_tb/tests/apb_uart_reg_test.sv"

module apb_uart_tb_top;

  // --------------------------------------------------------------------------
  // Interfaces
  // --------------------------------------------------------------------------
  ctrl_if ctrl ();                                          // clock and reset
  apb_if  apb  (.pclk(ctrl.clk), .presetn(ctrl.arst_n));    // APB bus
  uart_if tx   ();                                          // DUT TX line (testbench only listens)
  uart_if rx   ();                                          // DUT RX line (testbench drives it)

  // --------------------------------------------------------------------------
  // The DUT takes the APB bus as two structs, so convert to and from apb_if
  // --------------------------------------------------------------------------
  apb_req_t  apb_req;
  apb_resp_t apb_resp;
  logic      uart_irq;

  // apb_if -> request struct (any other struct fields are set to 0)
  always_comb begin
    apb_req         = '0;
    apb_req.psel    = apb.psel;
    apb_req.penable = apb.penable;
    apb_req.paddr   = apb.paddr;
    apb_req.pwrite  = apb.pwrite;
    apb_req.pwdata  = apb.pwdata;
  end

  // response struct -> apb_if
  assign apb.pready  = apb_resp.pready;
  assign apb.prdata  = apb_resp.prdata;
  assign apb.pslverr = apb_resp.pslverr;

  // --------------------------------------------------------------------------
  // DUT
  // --------------------------------------------------------------------------
  apb_uart_top dut (
    .PCLK       (ctrl.clk),
    .PRESETn    (ctrl.arst_n),

    .apb_req_i  (apb_req),
    .apb_resp_o (apb_resp),

    .UART_TX    (tx.line),
    .UART_RX    (rx.line),

    .UART_IRQ   (uart_irq)
  );

  // --------------------------------------------------------------------------
  // Give the virtual interfaces to the testbench.
  // The paths must match the ones the base test, drivers and monitors read.
  // --------------------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual ctrl_if)::set(null, "*.env.ctrl.*", "intf", ctrl);
    uvm_config_db#(virtual apb_if )::set(null, "*.env.apb.*",  "intf", apb);
    uvm_config_db#(virtual uart_if)::set(null, "*.env.tx.*",   "intf", tx);
    uvm_config_db#(virtual uart_if)::set(null, "*.env.rx.*",   "intf", rx);

    // Pick the test with +UVM_TESTNAME=<test class name>
    run_test();
  end

  // --------------------------------------------------------------------------
  // Waveform dump
  // --------------------------------------------------------------------------
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, apb_uart_tb_top);
  end

  // --------------------------------------------------------------------------
  // Stop a hung simulation (raise this for tests that send many bytes)
  // --------------------------------------------------------------------------
  initial begin
    #50ms;
    `uvm_fatal("TIMEOUT", "Simulation timed out")
  end

endmodule

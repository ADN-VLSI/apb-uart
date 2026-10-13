`ifndef __GUARD_APB_UART_SCBD_SV__
`define __GUARD_APB_UART_SCBD_SV__ 0

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uart_regif_pkg.sv"
import uart_regif_pkg::*;

`include "apb_uart_uvm_tb/object/apb_resp_item.sv"
`include "apb_uart_uvm_tb/object/uart_resp_item.sv"

// One write function per input: _apb, _uart_tx, _uart_rx
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_uart_tx)
`uvm_analysis_imp_decl(_uart_rx)

// ==============================================================================
// SCOREBOARD
//
// TX path: APB write to TXD  -> byte must appear on the UART TX line
// RX path: byte seen on UART RX line -> APB read of RXD must return it
// ==============================================================================
class apb_uart_scbd extends uvm_scoreboard;

  `uvm_component_utils(apb_uart_scbd)

  // Inputs from the monitors
  uvm_analysis_imp_apb     #(apb_resp_item,  apb_uart_scbd) apb_imp;
  uvm_analysis_imp_uart_tx #(uart_resp_item, apb_uart_scbd) uart_tx_imp;
  uvm_analysis_imp_uart_rx #(uart_resp_item, apb_uart_scbd) uart_rx_imp;

  // Bytes we are still waiting to see
  bit [7:0] tx_expected_q[$];
  bit [7:0] rx_expected_q[$];

  // Last value written to the CFG register (only bits [20:0] are used)
  bit [20:0] cfg_shadow;
  bit        cfg_valid = 0;

  // Result counters
  int pass = 0;
  int fail = 0;

  function new (string name = "apb_uart_scbd", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_imp     = new("apb_imp", this);
    uart_tx_imp = new("uart_tx_imp", this);
    uart_rx_imp = new("uart_rx_imp", this);
  endfunction

  // Compare one byte and update the counters
  function void compare_byte(string path, bit [7:0] expected, bit [7:0] actual);
    if (actual === expected) begin
      pass++;
      `uvm_info(get_type_name(), $sformatf("PASS: %s = 0x%02h", path, actual), UVM_LOW)
    end
    else begin
      fail++;
      `uvm_error(get_type_name(), $sformatf("FAIL: %s mismatch, expected 0x%02h, got 0x%02h", path, expected, actual))
    end
  endfunction

  // ----------------------------------------------------------------------------
  // APB monitor -> scoreboard
  // ----------------------------------------------------------------------------
  virtual function void write_apb(apb_resp_item item);
    // Skip transfers that ended with an error
    if (item.slverr === 1'b1) begin
      `uvm_warning(get_type_name(), $sformatf("APB SLVERR at addr 0x%02h, item ignored", item.addr))
      return;
    end

    // CPU wrote a byte to TXD: the same byte must come out on UART TX
    if (item.we === 1'b1 && item.addr == ADDR_TXD) begin
      tx_expected_q.push_back(item.data[7:0]);
      `uvm_info(get_type_name(), $sformatf("Expect 0x%02h on UART TX (queue depth=%0d)", item.data[7:0], tx_expected_q.size()), UVM_MEDIUM)
    end
    // CPU read RXD: it must return the next byte received on UART RX
    else if (item.we === 1'b0 && item.addr == ADDR_RXD) begin
      if (rx_expected_q.size() == 0) begin
        fail++;
        `uvm_error(get_type_name(), $sformatf("FAIL: RXD read 0x%02h but nothing was received on UART RX", item.data[7:0]))
      end
      else begin
        compare_byte("RXD read", rx_expected_q.pop_front(), item.data[7:0]);
      end
    end
    // CPU wrote CFG: remember the value
    else if (item.we === 1'b1 && item.addr == ADDR_CFG) begin
      cfg_shadow = item.data[20:0];
      cfg_valid  = 1;
    end
    // CPU read CFG: it must return the value that was last written
    else if (item.we === 1'b0 && item.addr == ADDR_CFG) begin
      if (cfg_valid) begin
        if (item.data[20:0] === cfg_shadow) begin
          pass++;
          `uvm_info(get_type_name(), $sformatf("PASS: CFG read-back = 0x%06h", item.data[20:0]), UVM_LOW)
        end
        else begin
          fail++;
          `uvm_error(get_type_name(), $sformatf("FAIL: CFG read-back mismatch, expected 0x%06h, got 0x%06h", cfg_shadow, item.data[20:0]))
        end
      end
    end
  endfunction

  // ----------------------------------------------------------------------------
  // UART TX monitor -> scoreboard (DUT sent a byte)
  // ----------------------------------------------------------------------------
  virtual function void write_uart_tx(uart_resp_item item);
    if (tx_expected_q.size() == 0) begin
      fail++;
      `uvm_error(get_type_name(), $sformatf("FAIL: unexpected byte 0x%02h on UART TX", item.data[7:0]))
    end
    else begin
      compare_byte("UART TX", tx_expected_q.pop_front(), item.data[7:0]);
    end
  endfunction

  // ----------------------------------------------------------------------------
  // UART RX monitor -> scoreboard (a byte was sent into the DUT)
  // ----------------------------------------------------------------------------
  virtual function void write_uart_rx(uart_resp_item item);
    rx_expected_q.push_back(item.data[7:0]);
    `uvm_info(get_type_name(), $sformatf("Expect 0x%02h from APB RXD read (queue depth=%0d)", item.data[7:0], rx_expected_q.size()), UVM_MEDIUM)
  endfunction

  // ----------------------------------------------------------------------------
  // End of test: nothing should be left in the queues
  // ----------------------------------------------------------------------------
  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (tx_expected_q.size() != 0) begin
      `uvm_error(get_type_name(), $sformatf("%0d byte(s) never appeared on UART TX", tx_expected_q.size()))
      fail += tx_expected_q.size();
    end
    if (rx_expected_q.size() != 0) begin
      `uvm_error(get_type_name(), $sformatf("%0d received byte(s) were never read from RXD", rx_expected_q.size()))
      fail += rx_expected_q.size();
    end
  endfunction

  // ----------------------------------------------------------------------------
  // Final summary
  // ----------------------------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    $display("");
    $display("========================================");
    $display("            TEST SUMMARY                ");
    $display("========================================");
    $display(" PASS = %0d", pass);
    $display(" FAIL = %0d", fail);
    $display("========================================");
    if (pass == 0 && fail == 0)
      $display(" NO TRANSACTIONS CHECKED");
    else if (fail == 0)
      $display(" ALL TESTS PASSED");
    else
      $display(" SOME TESTS FAILED");
    $display("========================================");
  endfunction

endclass

`endif

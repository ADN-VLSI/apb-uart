`ifndef __GUARD_APB_UART_SCBD_SV__
`define __GUARD_APB_UART_SCBD_SV__

// Create three distinct write() methods: write_apb, write_uart_tx, write_uart_rx
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_uart_tx)
`uvm_analysis_imp_decl(_uart_rx)

//------------------------------------------------------------------------------
// APB-UART Scoreboard
// Checks data integrity in both directions:
//   TX path: byte written to TXD over APB  ->  same byte seen on UART TX line
//   RX path: byte driven into UART RX line ->  same byte read from RXD over APB
// Expected bytes are kept in queues so ordering (FIFO) is also verified.
//------------------------------------------------------------------------------
class apb_uart_scbd extends uvm_scoreboard;

  // Register the class with the UVM factory
  `uvm_component_utils(apb_uart_scbd)

  //----------------------------------------------------------------------------
  // DUT register map (byte addresses)
  //----------------------------------------------------------------------------
  localparam bit [31:0] ADDR_CTRL   = 'h000;   // Control register
  localparam bit [31:0] ADDR_CFG    = 'h004;   // Configuration register
  localparam bit [31:0] ADDR_STATUS = 'h008;   // Status register
  localparam bit [31:0] ADDR_TXD    = 'h01c;   // Transmit data register
  localparam bit [31:0] ADDR_RXD    = 'h02c;   // Receive data register
  localparam bit [31:0] ADDR_INTR   = 'h030;   // Interrupt register

  //----------------------------------------------------------------------------
  // Analysis implementation ports (inputs to the scoreboard)
  //----------------------------------------------------------------------------
  uvm_analysis_imp_apb     #(apb_rsp_item,  apb_uart_scbd) apb_imp;      // From APB monitor
  uvm_analysis_imp_uart_tx #(uart_rsp_item, apb_uart_scbd) uart_tx_imp;  // From UART monitor
  uvm_analysis_imp_uart_rx #(uart_rsp_item, apb_uart_scbd) uart_rx_imp;  // From UART driver

  //----------------------------------------------------------------------------
  // Expected-data queues and counters
  //----------------------------------------------------------------------------
  bit [7:0]    tx_expected_q[$];     // Bytes written to TXD, waiting to appear on UART TX
  bit [7:0]    rx_expected_q[$];     // Bytes sent on UART RX, waiting to be read from RXD
  int unsigned pass_count = 0;       // Number of successful comparisons
  int unsigned fail_count = 0;       // Number of failed comparisons / errors

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name = "apb_uart_scbd", uvm_component parent = null);
    super.new(name, parent);         // Place this component in the UVM hierarchy
  endfunction

  //----------------------------------------------------------------------------
  // Build phase: create the analysis imps
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_imp     = new("apb_imp", this);
    uart_tx_imp = new("uart_tx_imp", this);
    uart_rx_imp = new("uart_rx_imp", this);
  endfunction

  //----------------------------------------------------------------------------
  // write_apb: called for every APB transfer seen by the APB monitor
  //----------------------------------------------------------------------------
  function void write_apb(apb_rsp_item item);

    // Ignore transfers the slave rejected, but warn so they are visible
    if (item.error) begin
      `uvm_warning("APB_SCB", $sformatf("APB SLVERR at address 0x%08h", item.addr))
      return;
    end

    // Write to TXD: the DUT should now transmit this byte on UART TX
    if (item.write && item.addr == ADDR_TXD) begin
      tx_expected_q.push_back(item.data[7:0]);    // Remember the byte for later comparison
      `uvm_info("APB_SCB",
                $sformatf("Expect TX byte 0x%02h (queue depth %0d)",
                          item.data[7:0], tx_expected_q.size()), UVM_MEDIUM)

    // Read from RXD: data must match the oldest byte received on UART RX
    end else if (!item.write && item.addr == ADDR_RXD) begin
      if (rx_expected_q.size() == 0) begin
        // Software read data that was never sent on the RX line
        fail_count++;
        `uvm_error("APB_SCB",
                   $sformatf("RXD read 0x%02h with no byte observed on UART RX",
                             item.rdata[7:0]))
      end else begin
        bit [7:0] expected;                       // Oldest byte still waiting to be read
        expected = rx_expected_q.pop_front();
        if (item.rdata[7:0] === expected) begin   // === also catches X/Z mismatches
          pass_count++;
          `uvm_info("APB_SCB",
                    $sformatf("RX data matched: 0x%02h", item.rdata[7:0]), UVM_LOW)
        end else begin
          fail_count++;
          `uvm_error("APB_SCB",
                     $sformatf("RX mismatch: expected 0x%02h, got 0x%02h",
                               expected, item.rdata[7:0]))
        end
      end

    // Other register accesses are only logged (not checked) at high verbosity
    end else if (item.write && item.addr == ADDR_CFG) begin
      `uvm_info("APB_SCB", $sformatf("UART config write: 0x%08h", item.data), UVM_HIGH)
    end else if (item.write && item.addr == ADDR_CTRL) begin
      `uvm_info("APB_SCB", $sformatf("UART control write: 0x%08h", item.data), UVM_HIGH)
    end else if (item.write && item.addr == ADDR_INTR) begin
      `uvm_info("APB_SCB", $sformatf("UART interrupt write: 0x%08h", item.data), UVM_HIGH)
    end else if (!item.write && item.addr == ADDR_STATUS) begin
      `uvm_info("APB_SCB", $sformatf("UART status read: 0x%08h", item.rdata), UVM_HIGH)
    end
  endfunction

  //----------------------------------------------------------------------------
  // write_uart_tx: called for every byte the UART monitor sees on the DUT TX line
  //----------------------------------------------------------------------------
  function void write_uart_tx(uart_rsp_item item);
    bit [7:0] discarded;             // Dummy sink for a dropped expected byte

    // Malformed frame: always a failure, never a pass
    if (item.framing_error || item.parity_error) begin
      fail_count++;
      `uvm_error("UART_TX_SCB", "UART TX monitor reported a framing or parity error")

      // Consume the matching expected byte so later transfers stay aligned
      if (tx_expected_q.size() != 0)
        discarded = tx_expected_q.pop_front();
      else
        `uvm_error("UART_TX_SCB",
                   $sformatf("Unexpected malformed UART TX byte 0x%02h", item.data))
      return;
    end

    // Good frame but nothing was written to TXD: DUT sent a byte on its own
    if (tx_expected_q.size() == 0) begin
      fail_count++;
      `uvm_error("UART_TX_SCB",
                 $sformatf("Unexpected UART TX byte 0x%02h", item.data))
    end else begin
      bit [7:0] expected;                         // Oldest byte written to TXD
      expected = tx_expected_q.pop_front();
      if (item.data === expected) begin
        pass_count++;
        `uvm_info("UART_TX_SCB",
                  $sformatf("TX data matched: 0x%02h", item.data), UVM_LOW)
      end else begin
        fail_count++;
        `uvm_error("UART_TX_SCB",
                   $sformatf("TX mismatch: expected 0x%02h, got 0x%02h",
                             expected, item.data))
      end
    end
  endfunction

  //----------------------------------------------------------------------------
  // write_uart_rx: called for every byte the UART driver sends into DUT RX
  //----------------------------------------------------------------------------
  function void write_uart_rx(uart_rsp_item item);

    // A malformed frame will not be received correctly, so do not expect it
    if (item.framing_error || item.parity_error) begin
      fail_count++;
      `uvm_error("UART_RX_SCB", "UART RX driver reported a framing or parity error")
      return;
    end

    // Remember the byte; it should later be read back through RXD over APB
    rx_expected_q.push_back(item.data);
    `uvm_info("UART_RX_SCB",
              $sformatf("Expect APB RXD byte 0x%02h (queue depth %0d)",
                        item.data, rx_expected_q.size()), UVM_MEDIUM)
  endfunction

  //----------------------------------------------------------------------------
  // check_phase: anything left in the queues at the end was never matched
  //----------------------------------------------------------------------------
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    // TX bytes written over APB but never seen on the UART line
    if (tx_expected_q.size() != 0) begin
      fail_count += tx_expected_q.size();
      `uvm_error("APB_UART_SCB",
                 $sformatf("%0d TX byte(s) were not observed", tx_expected_q.size()))
    end

    // RX bytes sent on the UART line but never read through APB
    if (rx_expected_q.size() != 0) begin
      fail_count += rx_expected_q.size();
      `uvm_error("APB_UART_SCB",
                 $sformatf("%0d RX byte(s) were not read through APB", rx_expected_q.size()))
    end
  endfunction

  //----------------------------------------------------------------------------
  // report_phase: print the final PASS/FAIL summary
  //----------------------------------------------------------------------------
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    // Plain $display summary (always visible in the log)
    $display("");
    $display("========================================");
    $display("       FINAL TEST SUMMARY               ");
    $display("========================================");
    $display(" PASS            = %0d", pass_count);
    $display(" FAIL            = %0d", fail_count);
    $display("========================================");
    if (fail_count == 0 && pass_count > 0 && tx_expected_q.size() == 0 && rx_expected_q.size() == 0)
      $display(" ALL TESTS PASSED");               // Clean run with real checks done
    else if (pass_count == 0 && fail_count == 0)
      $display(" NO TRANSACTIONS CHECKED");        // Nothing happened: likely a bad test
    else
      $display(" SOME TESTS FAILED");
    $display("========================================");

    // Same summary through UVM reporting (counted by the UVM report server)
    `uvm_info("APB_UART_SCB", "========================================", UVM_NONE)
    `uvm_info("APB_UART_SCB", "       FINAL TEST SUMMARY               ", UVM_NONE)
    `uvm_info("APB_UART_SCB", "========================================", UVM_NONE)
    `uvm_info("APB_UART_SCB", $sformatf(" PASS            = %0d", pass_count), UVM_NONE)
    `uvm_info("APB_UART_SCB", $sformatf(" FAIL            = %0d", fail_count), UVM_NONE)
    `uvm_info("APB_UART_SCB", "========================================", UVM_NONE)
    if (fail_count == 0 && pass_count > 0 && tx_expected_q.size() == 0 && rx_expected_q.size() == 0)
      `uvm_info("APB_UART_SCB", " ALL TESTS PASSED", UVM_NONE)
    else if (pass_count == 0 && fail_count == 0)
      `uvm_warning("APB_UART_SCB", " NO TRANSACTIONS CHECKED")
    else
      `uvm_error("APB_UART_SCB", " SOME TESTS FAILED")
    `uvm_info("APB_UART_SCB", "========================================", UVM_NONE)
  endfunction

endclass

`endif
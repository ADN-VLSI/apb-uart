`ifndef __GUARD_APB_UART_SCBD_SV__
`define __GUARD_APB_UART_SCBD_SV__ 0



`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_uart)

class apb_uart_scbd extends uvm_scoreboard;

  // ------------------------------------------------------------
  // UVM Component Registration
  // ------------------------------------------------------------

  `uvm_component_utils(apb_uart_scbd)

  // ------------------------------------------------------------
  // Analysis Implementation Ports
  // ------------------------------------------------------------

  uvm_analysis_imp_apb #(
    apb_rsp_item,
    apb_uart_scbd
  ) apb_export;

  uvm_analysis_imp_uart #(
    uart_rsp_item,
    apb_uart_scbd
  ) uart_export;

  // ------------------------------------------------------------
  // Expected TX Data Queue
  // ------------------------------------------------------------

  byte unsigned expected_tx_q[$];

  // ------------------------------------------------------------
  // Scoreboard State
  // ------------------------------------------------------------

  int unsigned apb_transaction_count;
  int unsigned uart_frame_count;
  int unsigned tx_match_count;
  int unsigned tx_mismatch_count;
  int unsigned apb_error_count;

  // Encoded UART data width:
  // 0 = 5 bits, 1 = 6 bits, 2 = 7 bits, 3 = 8 bits.
  int unsigned configured_data_bits = 8;

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(
    string name = "apb_uart_scbd",
    uvm_component parent = null
  );
    super.new(name, parent);

    apb_export  = new("apb_export", this);
    uart_export = new("uart_export", this);

  endfunction : new

  // ------------------------------------------------------------
  // APB Analysis Callback
  // ------------------------------------------------------------

  virtual function void write_apb(apb_rsp_item tr);

    byte unsigned expected_data;
    bit [31:0]    mask;

    apb_transaction_count++;

    `uvm_info(
      get_type_name(),
      $sformatf(
        "APB transaction: %s",
        tr.to_string()
      ),
      UVM_MEDIUM
    )

    // ----------------------------------------------------------
    // Check APB Slave Error
    // ----------------------------------------------------------

    if (tr.slverr) begin

      apb_error_count++;

      `uvm_error(
        get_type_name(),
        $sformatf(
          "APB slave error: we=%0b addr=0x%08h data=0x%08h",
          tr.we,
          tr.addr,
          tr.data
        )
      )

    end

    // ----------------------------------------------------------
    // Track UART Configuration
    // ----------------------------------------------------------

    if (tr.we && tr.addr == ADDR_CFG) begin

      case (tr.data[17:16])

        2'b00: configured_data_bits = 5;
        2'b01: configured_data_bits = 6;
        2'b10: configured_data_bits = 7;
        2'b11: configured_data_bits = 8;

        default: configured_data_bits = 8;

      endcase

      `uvm_info(
        get_type_name(),
        $sformatf(
          "UART data width configured to %0d bits",
          configured_data_bits
        ),
        UVM_MEDIUM
      )

    end

    // ----------------------------------------------------------
    // Capture Expected UART TX Data
    // ----------------------------------------------------------

    if (tr.we && tr.addr == ADDR_TXD) begin

      case (configured_data_bits)

        5: mask = 32'h0000_001F;
        6: mask = 32'h0000_003F;
        7: mask = 32'h0000_007F;
        8: mask = 32'h0000_00FF;

        default: mask = 32'h0000_00FF;

      endcase

      expected_data = tr.data[7:0] & mask[7:0];

      expected_tx_q.push_back(expected_data);

      `uvm_info(
        get_type_name(),
        $sformatf(
          "Expected UART TX byte queued: 0x%02h",
          expected_data
        ),
        UVM_MEDIUM
      )

    end

    // ----------------------------------------------------------
    // Observe APB Reads
    // ----------------------------------------------------------

    if (!tr.we && tr.addr == ADDR_RXD) begin

      `uvm_info(
        get_type_name(),
        $sformatf(
          "APB read UART_RXD: data=0x%02h",
          tr.data[7:0]
        ),
        UVM_MEDIUM
      )

    end

  endfunction : write_apb

  // ------------------------------------------------------------
  // UART Analysis Callback
  // ------------------------------------------------------------

  virtual function void write_uart(uart_rsp_item tr);

    byte unsigned expected_data;
    byte unsigned actual_data;

    uart_frame_count++;

    actual_data = tr.data;

    `uvm_info(
      get_type_name(),
      $sformatf(
        "Observed UART TX frame: %s",
        tr.to_string()
      ),
      UVM_MEDIUM
    )

    // ----------------------------------------------------------
    // Unexpected UART Frame
    // ----------------------------------------------------------

    if (expected_tx_q.size() == 0) begin

      tx_mismatch_count++;

      `uvm_error(
        get_type_name(),
        $sformatf(
          "Unexpected UART TX frame: data=0x%02h",
          actual_data
        )
      )

      return;

    end

    // ----------------------------------------------------------
    // Retrieve Expected Data
    // ----------------------------------------------------------

    expected_data = expected_tx_q.pop_front();

    // ----------------------------------------------------------
    // Compare Expected and Actual Data
    // ----------------------------------------------------------

    if (actual_data !== expected_data) begin

      tx_mismatch_count++;

      `uvm_error(
        get_type_name(),
        $sformatf(
          "UART TX mismatch: expected=0x%02h actual=0x%02h",
          expected_data,
          actual_data
        )
      )

    end
    else begin

      tx_match_count++;

      `uvm_info(
        get_type_name(),
        $sformatf(
          "UART TX PASS: data=0x%02h",
          actual_data
        ),
        UVM_LOW
      )

    end

  endfunction : write_uart

  // ------------------------------------------------------------
  // Report Phase
  // ------------------------------------------------------------

   virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    $display("");
    $display("========================================");
    $display("       FINAL TEST SUMMARY               ");
    $display("========================================");
    $display(" PASS            = %0d", tx_match_count);
    $display(" FAIL            = %0d", tx_mismatch_count);
    $display("========================================");
    if (tx_mismatch_count == 0 && tx_match_count > 0) begin
      $display(" ALL TESTS PASSED");
    end else if (tx_match_count == 0 && tx_mismatch_count == 0) begin
      $display(" NO TRANSACTIONS CHECKED");
    end else begin
      $display(" SOME TESTS FAILED");
    end
    $display("========================================");

  endfunction : report_phase



endclass : apb_uart_scbd

`endif
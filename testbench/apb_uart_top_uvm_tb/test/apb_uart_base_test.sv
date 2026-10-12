//------------------------------------------------------------------------------
// APB-UART Base Test
// Top of the UVM class hierarchy for this testbench. Creates the environment
// and provides a reusable helper task (apb_write). Other tests, such as
// apb_uart_write_test, can extend this class and override run_phase.
//------------------------------------------------------------------------------
class apb_uart_base_test extends uvm_test;

  // Register the class with the UVM factory
  `uvm_component_utils(apb_uart_base_test)

  //----------------------------------------------------------------------------
  // Handles
  //----------------------------------------------------------------------------
  apb_uart_env env;                         // Environment holding agents and scoreboard
  int unsigned test_cases_done = 0;
  int unsigned test_cases_passed = 0;
  int unsigned test_cases_failed = 0;
  localparam bit [31:0] RX_CFG_VALUE = 'h0003_0516;

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);                // Place this component in the UVM hierarchy
  endfunction

  //----------------------------------------------------------------------------
  // Build phase: create the environment
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_uart_env::type_id::create("env", this);
  endfunction

  //----------------------------------------------------------------------------
  // Helper task: perform one APB register write
  //----------------------------------------------------------------------------
  task apb_write(bit [31:0] addr, bit [31:0] data);
    apb_write_seq seq = apb_write_seq::type_id::create("apb_write_seq");

    seq.addr = addr;                        // Target register address
    seq.data = data;                        // Value to write
    seq.start(env.apb.sequencer);           // Run the sequence on the APB sequencer
  endtask

  // Count named test cases for the final test summary.
  function void record_test_case(string case_name, bit passed);
    test_cases_done++;
    if (passed) begin
      test_cases_passed++;
      $display("[TEST CASE] %s: PASS", case_name);
    end else begin
      test_cases_failed++;
      `uvm_error("TEST_CASE", $sformatf("%s: FAIL", case_name))
    end
  endfunction

  task run_tx_case(output bit passed);
    int unsigned pass_before;
    int unsigned fail_before;

    pass_before = env.scbd.pass_count;
    fail_before = env.scbd.fail_count;
    apb_write('h000, 'h8);
    apb_write('h004, 'h0003_28b1);
    apb_write('h01c, 'h0000_005a);
    #2ms;

    passed = (env.scbd.pass_count == pass_before + 1) &&
             (env.scbd.fail_count == fail_before) &&
             (env.scbd.tx_expected_q.size() == 0);
    if (!passed)
      `uvm_error("UART_TX_TEST", "TX byte 0x5A did not match on UART TX")
  endtask

  task run_rx_case(output bit passed);
    uart_send_seq uart_seq;
    apb_read_seq apb_seq;
    bit [7:0] test_data[3] = '{8'h00, 8'h5a, 8'hff};
    int unsigned pass_before;
    int unsigned fail_before;
    bit reads_match;
    // RX samples 8 times per serial bit, so its input clock must be 8x 9600 baud.

    pass_before = env.scbd.pass_count;
    fail_before = env.scbd.fail_count;
    reads_match = 1'b1;
    apb_write('h004, RX_CFG_VALUE);
    // Let the clock divider settle after changing from the TX baud setting.
    #2ms;
    apb_write('h000, 'h10);

    foreach (test_data[i]) begin
      uart_seq = uart_send_seq::type_id::create($sformatf("uart_seq_byte%0d", i));
      uart_seq.data = test_data[i];
      uart_seq.baud = 9600;
      uart_seq.start(env.uart.sequencer);
      #2ms;

      apb_seq = apb_read_seq::type_id::create($sformatf("apb_read_byte%0d", i));
      apb_seq.addr = 'h02c;
      apb_seq.start(env.apb.sequencer);
      // Let the APB monitor deliver its analysis transaction to the scoreboard.
      #10ns;
      if (apb_seq.rdata[7:0] !== test_data[i]) begin
        reads_match = 1'b0;
        `uvm_error("UART_RX_TEST",
                   $sformatf("RXD mismatch for byte %0d: expected 0x%02h, got 0x%02h",
                             i, test_data[i], apb_seq.rdata[7:0]))
      end
    end

    passed = (reads_match === 1'b1) &&
             (env.scbd.pass_count == pass_before + 3) &&
             (env.scbd.fail_count == fail_before) &&
             (env.scbd.rx_expected_q.size() == 0);
    if (!passed)
      `uvm_error("UART_RX_TEST", "One or more RX bytes failed scoreboard checking")
  endtask

  task run_cfg_case(output bit passed);
    apb_read_seq read_seq;
    apb_write('h004, 'h0003_28b1);
    read_seq = apb_read_seq::type_id::create("cfg_readback_seq");
    read_seq.addr = 'h004;
    read_seq.start(env.apb.sequencer);
    passed = (read_seq.rdata === 'h0003_28b1);
    if (!passed)
      `uvm_error("UART_CFG_TEST",
                 $sformatf("CFG readback mismatch: expected 0x000328B1, got 0x%08h",
                           read_seq.rdata))
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("[TEST CASE SUMMARY] %s DONE=%0d PASS=%0d FAIL=%0d",
             get_type_name(), test_cases_done, test_cases_passed, test_cases_failed);
  endfunction

  //----------------------------------------------------------------------------
  // Run phase: execute all functional test cases once
  //----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    bit passed;
    phase.raise_objection(this);

    #200ns;

    run_tx_case(passed);
    record_test_case("UART TX write", passed);

    run_rx_case(passed);
    record_test_case("UART RX readback (00, 5A, FF)", passed);

    run_cfg_case(passed);
    record_test_case("CFG register readback", passed);

    phase.drop_objection(this);
  endtask

endclass

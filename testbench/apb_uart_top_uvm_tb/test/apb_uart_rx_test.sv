//------------------------------------------------------------------------------
// APB-UART RX Test
// Verifies the DUT receive path. For each test byte:
//   1. The UART driver sends the byte serially into the DUT RX line
//   2. The test waits until the frame has been fully received
//   3. The byte is read back from the RXD register over APB and checked
// The scoreboard independently checks the same data (UART RX -> APB RXD).
//------------------------------------------------------------------------------
class apb_uart_rx_test extends apb_uart_base_test;

  // Register the class with the UVM factory
  `uvm_component_utils(apb_uart_rx_test)

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);                // Place this component in the UVM hierarchy
  endfunction

  //----------------------------------------------------------------------------
  // Run phase: configure the DUT, then send and read back each byte
  //----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    uart_send_seq uart_seq;                 // Sends one byte into DUT RX
    apb_read_seq  apb_seq;                  // Reads one register over APB
    bit [7:0]     test_data[3] = '{8'h00, 8'h5a, 8'hff};   // All-zeros, mixed, all-ones

    phase.raise_objection(this);            // Keep the simulation alive while we work

    // Enable the receiver and use the same 8-N-1, 9600 baud setting
    // as the UART interface stimulus.
    apb_write('h000, 'h10);                 // CTRL register: enable receiver
    apb_write('h004, 'h0003_28b1);          // CFG register: 8-N-1, 9600 baud

    foreach (test_data[i]) begin
      // Send one byte into the DUT RX line
      uart_seq = uart_send_seq::type_id::create($sformatf("uart_seq_%0d", i));
      uart_seq.data = test_data[i];         // Byte to send
      uart_seq.baud = 9600;                 // Must match the DUT baud configuration
      uart_seq.start(env.uart.sequencer);   // Run on the UART sequencer

      // Allow the complete UART frame to be received before reading RXD.
      #2ms;

      // Read the received byte back through APB
      apb_seq = apb_read_seq::type_id::create($sformatf("apb_read_seq_%0d", i));
      apb_seq.addr = 'h02c;                 // RXD register
      apb_seq.start(env.apb.sequencer);     // Run on the APB sequencer

      // Direct check in the test (the scoreboard checks the same data too)
      if (apb_seq.rdata[7:0] !== test_data[i]) begin
        `uvm_error("UART_RX_TEST",
                   $sformatf("RXD mismatch: expected 0x%02h, got 0x%02h",
                             test_data[i], apb_seq.rdata[7:0]))
      end
    end

    phase.drop_objection(this);             // Allow the simulation to end
  endtask

endclass
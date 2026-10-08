`include "../include/adn_apb_uart_top_uvm_pkg.sv"   // Pulls in all UVM classes (package)

//------------------------------------------------------------------------------
// APB-UART Top-level Testbench Module
// Generates clock and reset, instantiates the interfaces and the DUT, connects
// them together, publishes the virtual interfaces to the UVM config DB and
// starts the selected UVM test.
//------------------------------------------------------------------------------
module apb_uart_top_uvm_tb;

  import uvm_pkg::*;
  import adn_apb_uart_top_uvm_pkg::apb_uart_write_test;   // Make test visible to this module
  import adn_apb_uart_top_uvm_pkg::apb_uart_rx_test;      // Make test visible to this module

  //----------------------------------------------------------------------------
  // Clock, reset and DUT-side signals
  //----------------------------------------------------------------------------
  logic pclk = 0;                           // APB clock
  logic presetn;                            // Active-low reset
  logic irq;                                // DUT interrupt output (not used by the TB)
  logic uart_tx;                            // DUT UART TX output

  always #5ns pclk = ~pclk;                 // 10 ns period = 100 MHz clock

  //----------------------------------------------------------------------------
  // Interfaces
  //----------------------------------------------------------------------------
  apb_if      apb(presetn, pclk);           // APB interface (reset, clock)
  adn_uart_if uart();                       // UART interface (line + drive control)

  //----------------------------------------------------------------------------
  // Struct-based APB connection to the DUT
  //----------------------------------------------------------------------------
  apb_req_t  apb_req;                       // Request struct going into the DUT
  apb_resp_t apb_resp;                      // Response struct coming from the DUT

  // Interface signals -> DUT request struct
  always_comb begin
    apb_req.psel    = apb.psel;
    apb_req.penable = apb.penable;
    apb_req.paddr   = apb.paddr;
    apb_req.pprot   = apb.pprot;
    apb_req.pwrite  = apb.pwrite;
    apb_req.pwdata  = apb.pwdata;
    apb_req.pstrb   = apb.pstrb;
  end

  // DUT response struct -> interface signals
  assign apb.pready  = apb_resp.pready;
  assign apb.prdata  = apb_resp.prdata;
  assign apb.pslverr = apb_resp.pslverr;

  //----------------------------------------------------------------------------
  // UART line multiplexer
  // drive_enable = 1 : testbench drives the DUT RX line (tx_driver)
  // drive_enable = 0 : the line follows the DUT TX output
  // The same net feeds DUT UART_RX and is sampled by uart_monitor.
  //----------------------------------------------------------------------------
  assign uart.line = uart.drive_enable ? uart.tx_driver : uart_tx;

  //----------------------------------------------------------------------------
  // Device under test
  //----------------------------------------------------------------------------
  apb_uart_top dut (
    .PCLK      (pclk),
    .PRESETn   (presetn),
    .apb_req_i (apb_req),
    .apb_resp_o(apb_resp),
    .UART_TX   (uart_tx),
    .UART_RX   (uart.line),
    .UART_IRQ  (irq)
  );

  //----------------------------------------------------------------------------
  // Test startup
  //----------------------------------------------------------------------------
  initial begin
    string test_name;                       // Test chosen from the command line

    // Reference the test classes so they are linked in and registered with the factory
    void'(apb_uart_write_test::type_id::get());
    void'(apb_uart_rx_test::type_id::get());

    // Initial state: reset asserted, APB bus idle
    presetn = 0;
    apb.reset();

    // Initial UART interface settings
    uart.drive_enable = 0;                  // TB not driving the line yet
    uart.baud_rate    = 9600;
    uart.data_bits    = 8;
    uart.parity_en    = 0;                  // No parity
    uart.parity_type  = 0;
    uart.extra_stop   = 0;                  // 1 stop bit

    // Publish virtual interfaces (must happen before run_test builds the env)
    uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", apb);
    uvm_config_db#(virtual adn_uart_if)::set(null, "*", "uart_vif", uart);

    // Select test with +TN=<name>; default is the write test
    if (!$value$plusargs("TN=%s", test_name) || test_name == "default")
      test_name = "apb_uart_write_test";

    fork
      run_test(test_name);                  // Start UVM and run the chosen test
      begin
        repeat (5) @(posedge pclk);         // Hold reset for 5 clock cycles
        presetn = 1;                        // Release reset
      end
    join
  end

endmodule
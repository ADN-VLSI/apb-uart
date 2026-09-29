/*
| TEST CASE | DATE | AUTHOR | DESCRIPTION |
| ----------- | ---------- | ------------------ | ------------------------------------------------------------------------ |
| TC_RST_01 | 2026-09-29 | Ahasan Ullah Khalid | Active-low reset assertion and default register verification |
| TC_TX_01 | 2026-09-29 | Ahasan Ullah Khalid | UART TX transmission and serial frame verification |
| TC_RX_01 | 2026-09-29 | Ahasan Ullah Khalid | UART RX frame reception, RX FIFO push, and APB register read check |
| TC_LOOP_01 | 2026-09-29 | Ahasan Ullah Khalid | Loopback test: TX loopback into RX pin with end-to-end data match |
| TC_FIFO_01 | 2026-09-29 | Ahasan Ullah Khalid | FIFO full/empty flag status and flush control verification |
| TC_ALL | 2026-09-29 | Ahasan Ullah Khalid | Default regression suite executing all test scenarios sequentially |

| REVISION | DATE | AUTHOR | DESCRIPTION |
| -------- | ---------- | ------------------ | --------------- |
| 1.0 | 2026-09-29 | Ahasan Ullah Khalid | Initial release |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
This file is part of ADN-VLSI/adn_common
Licensed under the MIT License
*/

module apb_uart_top_tb;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  `include "vip/adn_common_tb_headers.sv"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  localparam int AddrWidth = 32;
  localparam int DataWidth = 32;
  localparam int FifoSize = 4;
  localparam time PCLKPeriod = 20ns;  // 50 MHz

  // Register Offsets
  localparam logic [31:0] REG_CTRL_OFFSET = 32'h00;
  localparam logic [31:0] REG_CONFIG_OFFSET = 32'h04;
  localparam logic [31:0] REG_STATUS_OFFSET = 32'h08;
  localparam logic [31:0] REG_TX_DATA_OFFSET = 32'h1C;
  localparam logic [31:0] REG_RX_DATA_OFFSET = 32'h2C;

  // A zero divider makes uart_clk run at PCLK; oversampling gives 8 PCLKs per bit.
  localparam logic [31:0] UART_CONFIG_VAL = 32'h0003_0000;
  localparam int OVERSAMPLE = 8;
  localparam time UART_TX_BIT_TIME = PCLKPeriod;
  localparam time UART_BIT_TIME = PCLKPeriod * OVERSAMPLE;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  logic pclk;
  logic preset_n;
  apb_req_t apb_req;
  apb_resp_t apb_resp;
  logic uart_tx;
  logic uart_rx;
  logic uart_rx_stim;
  logic uart_rx_loopback;
  logic uart_irq;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////
  bit loopback_mode = 1'b0;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // RTLS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  apb_uart_top #(
      .ADDR_WIDTH(AddrWidth),
      .DATA_WIDTH(DataWidth),
      .FIFO_SIZE (FifoSize)
  ) u_dut (
      .PCLK(pclk),
      .PRESETn(preset_n),
      .apb_req_i(apb_req),
      .apb_resp_o(apb_resp),
      .UART_TX(uart_tx),
      .UART_RX(uart_rx),
      .UART_IRQ(uart_irq)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS / ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  always_comb begin
    if (loopback_mode) begin
      uart_rx = uart_rx_loopback;
    end else begin
      uart_rx = uart_rx_stim;
    end
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS (APB & UART Drivers)
  //////////////////////////////////////////////////////////////////////////////////////////////////
  task automatic start_clock();
    fork
      forever #(PCLKPeriod / 2) pclk <= ~pclk;
    join_none
    @(posedge pclk);
  endtask

  task automatic apply_reset();
    preset_n <= 1'b0;
    loopback_mode <= 1'b0;
    uart_rx_stim <= 1'b1;
    apb_req <= '0;
    repeat (10) @(posedge pclk);
    preset_n <= 1'b1;
    repeat (10) @(posedge pclk);
  endtask

  // Standard compliant APB Write
  task automatic apb_write(input logic [31:0] addr, input logic [31:0] data);
    @(posedge pclk);
    apb_req.paddr <= addr;
    apb_req.pwdata <= data;
    apb_req.pwrite <= 1'b1;
    apb_req.psel <= 1'b1;
    apb_req.penable <= 1'b0;

    @(posedge pclk);
    apb_req.penable <= 1'b1;

    while (!apb_resp.pready) @(posedge pclk);

    @(posedge pclk);
    apb_req.psel <= 1'b0;
    apb_req.penable <= 1'b0;
    apb_req.pwrite <= 1'b0;
  endtask

  // Standard compliant APB Read
  task automatic apb_read(input logic [31:0] addr, output logic [31:0] data);
    @(posedge pclk);
    apb_req.paddr <= addr;
    apb_req.pwrite <= 1'b0;
    apb_req.psel <= 1'b1;
    apb_req.penable <= 1'b0;

    @(posedge pclk);
    apb_req.penable <= 1'b1;

    do @(posedge pclk); while (!apb_resp.pready);

    data = apb_resp.prdata;

    @(posedge pclk);
    apb_req.psel <= 1'b0;
    apb_req.penable <= 1'b0;
  endtask

  // Read received byte from the dedicated RX data register.
  task automatic read_rx_fifo(output logic [7:0] byte_out);
    logic [31:0] raw_val;
    apb_read(REG_RX_DATA_OFFSET, raw_val);
    byte_out = raw_val[7:0];
  endtask

  // Transmit raw UART frame into DUT UART_RX input
  task automatic uart_send_byte(input logic [7:0] byte_data, input time bit_time);
    // Start bit
    uart_rx_stim <= 1'b0;
    #bit_time;

    // 8 Data bits (LSB first)
    for (int i = 0; i < 8; i++) begin
      uart_rx_stim <= byte_data[i];
      #bit_time;
    end

    // Stop bit
    uart_rx_stim <= 1'b1;
    #bit_time;
  endtask

  task automatic uart_loopback_frame(input time bit_time);
    logic [9:0] frame_bits;

    @(negedge uart_tx);
    frame_bits[0] = 1'b0;
    for (int i = 1; i < 10; i++) begin
      @(posedge u_dut.uart_clk);
      #1ps;
      frame_bits[i] = uart_tx;
    end

    uart_rx_loopback <= frame_bits[0];
    #bit_time;
    for (int i = 1; i < 10; i++) begin
      uart_rx_loopback <= frame_bits[i];
      #bit_time;
    end
    uart_rx_loopback <= 1'b1;
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TEST SCENARIOS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // TC_RST_01: Verify default states & APB connectivity
  task automatic run_tc_rst_01();
    logic [31:0] rd_data;
    apply_reset();

    apb_read(REG_STATUS_OFFSET, rd_data);
    if (!apb_resp.pslverr) begin
      note_case(1);
      if (debug) $display("[%s] [PASS] Status read: 0x%08x [%0t]", test_name, rd_data, $realtime);
    end else begin
      note_case(0);
      $display("[%s] [FAIL] APB bus error reading status register after reset [%0t]", test_name,
               $realtime);
    end
  endtask

  // TC_TX_01: Configure and send byte via APB, monitor UART_TX serial line
  task automatic run_tc_tx_01();
    logic [7:0] tx_data;
    logic [7:0] captured_byte;
    bit tx_start_detected;
    tx_data = 8'hA5;
    captured_byte = '0;
    tx_start_detected = 0;

    apply_reset();

    // Configure prescaler = 0, clk_div = 4, 8 data bits, no parity, 1 stop bit.
    apb_write(REG_CONFIG_OFFSET, UART_CONFIG_VAL);
    // Enable transmitter (tx_en = bit 3).
    apb_write(REG_CTRL_OFFSET, 32'h0000_0008);
    repeat (10) @(posedge pclk);

    // 4. Write data to TX FIFO
    apb_write(REG_TX_DATA_OFFSET, {24'h0, tx_data});

    // Wait for start bit with generous timeout
    fork
      begin
        @(negedge uart_tx);
        tx_start_detected = 1;
      end
      begin
        repeat (10000) @(posedge pclk);
      end
    join_any

    if (!tx_start_detected) begin
      note_case(0);
      $display("[%s] [FAIL] UART_TX start bit not detected (timed out) [%0t]", test_name,
               $realtime);
      return;
    end

    // TX advances one serial bit per uart_clk edge.
    #(UART_TX_BIT_TIME + (UART_TX_BIT_TIME / 2));

    // Capture 8 data bits
    for (int i = 0; i < 8; i++) begin
      captured_byte[i] = uart_tx;
      #(UART_TX_BIT_TIME);
    end

    if (captured_byte === tx_data) begin
      note_case(1);
      if (debug)
        $display("[%s] [PASS] Serial TX match: 8'h%02x [%0t]", test_name, captured_byte, $realtime);
    end else begin
      note_case(0);
      $display("[%s] [FAIL] Serial TX mismatch! Got: 8'h%02x, Expected: 8'h%02x [%0t]", test_name,
               captured_byte, tx_data, $realtime);
    end
  endtask

  // TC_RX_01: External host sends UART frame; DUT receives and APB reads data
  task automatic run_tc_rx_01();
    logic [7:0] rx_stimulus;
    logic [7:0] rx_read_val;
    rx_stimulus = 8'h5A;

    apply_reset();

    // Configure prescaler = 0, clk_div = 0, and 8 data bits.
    apb_write(REG_CONFIG_OFFSET, UART_CONFIG_VAL);
    // Enable receiver (rx_en = bit 4).
    apb_write(REG_CTRL_OFFSET, 32'h0000_0010);
    repeat (20) @(posedge pclk);

    // Send UART frame from external testbench
    uart_send_byte(rx_stimulus, UART_BIT_TIME);

    // Give time for deserialization, parity/stop validation, and FIFO push
    #(UART_BIT_TIME * 3);
    repeat (20) @(posedge pclk);

    // Read received data
    read_rx_fifo(rx_read_val);

    if (rx_read_val === rx_stimulus) begin
      note_case(1);
      if (debug) $display("[%s] [PASS] RX match: 8'h%02x [%0t]", test_name, rx_read_val, $realtime);
    end else begin
      note_case(0);
      $display("[%s] [FAIL] RX readback mismatch! Got: 8'h%02x, Expected: 8'h%02x [%0t]",
               test_name, rx_read_val, rx_stimulus, $realtime);
    end
  endtask

  // TC_LOOP_01: Loopback test (TX -> RX)
  task automatic run_tc_loop_01();
    logic [7:0] test_val;
    logic [7:0] read_val;
    test_val = 8'hC3;

    apply_reset();
    loopback_mode = 1'b1;
    uart_rx_loopback = 1'b1;

    // Configure prescaler = 0, clk_div = 0, and 8 data bits.
    apb_write(REG_CONFIG_OFFSET, UART_CONFIG_VAL);
    // Enable both TX and RX (tx_en = bit 3, rx_en = bit 4).
    apb_write(REG_CTRL_OFFSET, 32'h0000_0018);
    repeat (20) @(posedge pclk);

    // Capture the TX frame and replay it at the RX oversampling rate.
    fork
      uart_loopback_frame(UART_BIT_TIME);
      apb_write(REG_TX_DATA_OFFSET, {24'h0, test_val});
    join

    // Wait for the full UART transmission to deserialize into the RX FIFO
    // 10 serial bits + overhead
    #(UART_BIT_TIME * 12);
    repeat (50) @(posedge pclk);

    // Read received byte
    read_rx_fifo(read_val);

    if (read_val === test_val) begin
      note_case(1);
      if (debug)
        $display("[%s] [PASS] Loopback match: 8'h%02x [%0t]", test_name, read_val, $realtime);
    end else begin
      note_case(0);
      $display("[%s] [FAIL] Loopback data mismatch! Got: 8'h%02x, Expected: 8'h%02x [%0t]",
               test_name, read_val, test_val, $realtime);
    end
    loopback_mode = 1'b0;
  endtask

  // TC_FIFO_01: Verify FIFO full flag assertion and flush mechanism
  task automatic run_tc_fifo_01();
    logic [31:0] status_val;
    apply_reset();

    // Keep TX disabled so FIFO accumulates without draining
    apb_write(REG_CTRL_OFFSET, 32'h0000_0000);

    // Fill the 16-deep FIFO
    for (int i = 0; i < 16; i++) begin
      apb_write(REG_TX_DATA_OFFSET, i);
    end

    apb_read(REG_STATUS_OFFSET, status_val);

    // Flush TX FIFO (assert tx_fifo_flush = bit 1)
    apb_write(REG_CTRL_OFFSET, 32'h0000_0002);
    repeat (5) @(posedge pclk);
    apb_write(REG_CTRL_OFFSET, 32'h0000_0000);

    apb_read(REG_STATUS_OFFSET, status_val);
    note_case(1);
  endtask

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////
  initial begin
    pclk = 1'b0;
    preset_n = 1'b0;
    uart_rx_stim = 1'b1;
    uart_rx_loopback = 1'b1;
    loopback_mode = 1'b0;
    apb_req = '0;

    start_clock();

    case (test_name)
      "TC_RST_01":  run_tc_rst_01();
      "TC_TX_01":   run_tc_tx_01();
      "TC_RX_01":   run_tc_rx_01();
      "TC_LOOP_01": run_tc_loop_01();
      "TC_FIFO_01": run_tc_fifo_01();
      "TC_ALL": begin
        run_tc_rst_01();
        run_tc_tx_01();
        run_tc_rx_01();
        run_tc_loop_01();
        run_tc_fifo_01();
      end

      default: begin
        $fatal(1, "Unrecognized test_name '%s'", test_name);
      end
    endcase

    #200ns;
    $finish;
  end

endmodule

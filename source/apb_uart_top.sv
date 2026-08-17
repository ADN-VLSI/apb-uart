/*

@foez-bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez-bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-08-13 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | 2026-08-17 | Ahasan Ullah Khalid | Stable release                                         |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
This file is part of ADN-VLSI/apb_uart
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez-bhai, add comments to the parameters, ports
module apb_uart_top #(
    parameter int APB_ADDR_WIDTH = 32,
    parameter int APB_DATA_WIDTH = 32,
    parameter int FIFO_SIZE      = 4    // log2(16) -> Depth of 16 for FIFOs
) (
    // APB Bus Interface
    input  logic                      PCLK,
    input  logic                      PRESETn,
    input  logic [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    input  logic                      PWRITE,
    input  logic [APB_DATA_WIDTH-1:0] PWDATA,
    output logic [APB_DATA_WIDTH-1:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR,

    // UART External Interface
    output logic UART_TX,
    input  logic UART_RX,

    // Interrupt
    output logic UART_IRQ
);

  // @foez-bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // APB-to-Register translated signals
  logic               reg_write_en;
  logic               reg_read_en;

  // Hardware Control (from Register Block)
  logic               uart_sw_rst;
  logic               datapath_rst_n;
  logic               tx_fifo_rst_n;
  logic               rx_fifo_rst_n;
  logic               tx_fifo_flush;
  logic               rx_fifo_flush;
  logic               tx_en;
  logic               rx_en;
  logic [       11:0] clk_div;
  logic [        3:0] prescaler;
  logic [        1:0] data_bits;
  logic               parity_en;
  logic               parity_type;
  logic               stop_bits;

  // FIFO Status
  logic [        9:0] tx_data_cnt;
  logic [        9:0] rx_data_cnt;
  logic [FIFO_SIZE:0] tx_fifo_count;
  logic [FIFO_SIZE:0] rx_fifo_count;
  logic               tx_fifo_empty;
  logic               tx_fifo_full;
  logic               rx_fifo_empty;
  logic               rx_fifo_full;

  // TX Datapath
  logic [        7:0] tx_fifo_wdata;
  logic               tx_fifo_push;  // From APB
  logic               tx_fifo_ready_in;  // To APB
  logic [        7:0] tx_fifo_rdata;  // To Tx
  logic               tx_fifo_valid_out;  // To Tx
  logic               tx_ready_in;  // From Tx

  // RX Datapath
  logic [        7:0] rx_fifo_wdata;  // From Rx
  logic               rx_data_valid_out;  // From Rx
  logic               rx_fifo_push;  // To RX FIFO
  logic               rx_fifo_ready_in;  // From RX FIFO
  logic [        7:0] rx_fifo_rdata;  // To APB
  logic               rx_fifo_pop;  // From APB
  logic               rx_fifo_valid_out;  // From RX FIFO

  // Generated Clock
  logic               uart_clk;

  // Arbitration (Unused/Tied-off in single master)
  logic [        7:0] tx_access_req_id;
  logic               tx_req_valid;
  logic               tx_grant_pop;
  logic [        7:0] rx_access_req_id;
  logic               rx_req_valid;
  logic               rx_grant_pop;

  // Interrupt Enables
  logic               tx_fifo_empty_int_en;
  logic               tx_fifo_full_int_en;
  logic               rx_fifo_empty_int_en;
  logic               rx_fifo_full_int_en;
  logic               tx_data_valid_masked;

  // Interrupt Controller
  logic               tx_empty_irq;
  logic               tx_full_irq;
  logic               rx_empty_irq;
  logic               rx_full_irq;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // APB to Register Bus Bridge
  always_comb reg_write_en = PSEL & PENABLE & PWRITE;
  always_comb reg_read_en = PSEL & PENABLE & ~PWRITE;

  // Datapath Reset Management
  always_comb datapath_rst_n = PRESETn & ~uart_sw_rst;
  always_comb tx_fifo_rst_n = datapath_rst_n & ~tx_fifo_flush;
  always_comb rx_fifo_rst_n = datapath_rst_n & ~rx_fifo_flush;

  // Status flag logic translation mapping
  always_comb tx_fifo_full = ~tx_fifo_ready_in;
  always_comb tx_fifo_empty = ~tx_fifo_valid_out;
  always_comb rx_fifo_full = ~rx_fifo_ready_in;
  always_comb rx_fifo_empty = ~rx_fifo_valid_out;

  // Zero-pad variable sized count flags for fixed width 10-bit APB registers
  always_comb tx_data_cnt = {{(10 - FIFO_SIZE - 1) {1'b0}}, tx_fifo_count};
  always_comb rx_data_cnt = {{(10 - FIFO_SIZE - 1) {1'b0}}, rx_fifo_count};

  // Mask Rx data entry unless Receiver is enabled
  always_comb rx_fifo_push = rx_data_valid_out & rx_en;

  // Valid input to Tx is logically masked by the transmitter enable bit
  always_comb tx_data_valid_masked = tx_fifo_valid_out & tx_en;

  // Interrupt Controller
  always_comb begin
    tx_empty_irq = tx_fifo_empty & tx_fifo_empty_int_en;
    tx_full_irq = tx_fifo_full & tx_fifo_full_int_en;
    rx_empty_irq = rx_fifo_empty & rx_fifo_empty_int_en;
    rx_full_irq = rx_fifo_full & rx_fifo_full_int_en;
    UART_IRQ = tx_empty_irq | tx_full_irq | rx_empty_irq | rx_full_irq;
  end

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Register Interface
  adn_uart_register_interface #(
      .ADDR_WIDTH(APB_ADDR_WIDTH),
      .DATA_WIDTH(APB_DATA_WIDTH)
  ) u_reg_intf (
      .clk  (PCLK),
      .rst_n(PRESETn),

      .reg_addr    (PADDR),
      .reg_wdata   (PWDATA),
      .reg_write_en(reg_write_en),
      .reg_read_en (reg_read_en),
      .reg_rdata   (PRDATA),
      .reg_ready   (PREADY),
      .reg_error   (PSLVERR),

      .uart_sw_rst  (uart_sw_rst),
      .tx_fifo_flush(tx_fifo_flush),
      .rx_fifo_flush(rx_fifo_flush),
      .tx_en        (tx_en),
      .rx_en        (rx_en),
      .clk_div      (clk_div),
      .prescaler    (prescaler),
      .data_bits    (data_bits),
      .parity_en    (parity_en),
      .parity_type  (parity_type),
      .stop_bits    (stop_bits),

      .tx_data_cnt  (tx_data_cnt),
      .rx_data_cnt  (rx_data_cnt),
      .tx_fifo_empty(tx_fifo_empty),
      .tx_fifo_full (tx_fifo_full),
      .rx_fifo_empty(rx_fifo_empty),
      .rx_fifo_full (rx_fifo_full),

      .tx_fifo_wdata(tx_fifo_wdata),
      .tx_fifo_push (tx_fifo_push),
      .rx_fifo_rdata(rx_fifo_rdata),
      .rx_fifo_pop  (rx_fifo_pop),

      .tx_access_req_id(tx_access_req_id),
      .tx_req_valid    (tx_req_valid),
      .tx_grant_id     (8'h01),
      .tx_grant_valid  (1'b1),
      .tx_grant_pop    (tx_grant_pop),

      .rx_access_req_id(rx_access_req_id),
      .rx_req_valid    (rx_req_valid),
      .rx_grant_id     (8'h01),
      .rx_grant_valid  (1'b1),
      .rx_grant_pop    (rx_grant_pop),

      .tx_fifo_empty_int_en(tx_fifo_empty_int_en),
      .tx_fifo_full_int_en (tx_fifo_full_int_en),
      .rx_fifo_empty_int_en(rx_fifo_empty_int_en),
      .rx_fifo_full_int_en (rx_fifo_full_int_en)
  );

  // 3. Clock Divider
  adn_clk_rst_clk_div #(
      .DIV_WIDTH(16)
  ) u_clk_div (
      .arst_ni(datapath_rst_n),
      .clk_i  (PCLK),
      .div_i  ({prescaler, clk_div}),
      .clk_o  (uart_clk)
  );

  adn_common_fifo #(
      .DATA_WIDTH(8),
      .FIFO_SIZE (FIFO_SIZE),
      .PIPELINED (1)
  ) u_tx_fifo (
      .arst_ni(tx_fifo_rst_n),
      .clk_i  (PCLK),

      // Write Port (From APB Register Block)
      .data_in_i      (tx_fifo_wdata),
      .data_in_valid_i(tx_fifo_push),
      .data_in_ready_o(tx_fifo_ready_in),

      .count_o(tx_fifo_count),

      // Read Port (To UART Transmitter)
      .data_out_o      (tx_fifo_rdata),
      .data_out_valid_o(tx_fifo_valid_out),
      .data_out_ready_i(tx_ready_in)
  );

  adn_common_fifo #(
      .DATA_WIDTH(8),
      .FIFO_SIZE (FIFO_SIZE),
      .PIPELINED (1)
  ) u_rx_fifo (
      .arst_ni(rx_fifo_rst_n),
      .clk_i  (PCLK),

      // Write Port (From UART Receiver)
      .data_in_i      (rx_fifo_wdata),
      .data_in_valid_i(rx_fifo_push),
      .data_in_ready_o(rx_fifo_ready_in),

      .count_o(rx_fifo_count),

      // Read Port (To APB Register Block)
      .data_out_o      (rx_fifo_rdata),
      .data_out_valid_o(rx_fifo_valid_out),
      .data_out_ready_i(rx_fifo_pop)
  );

  adn_uart_transmitter #(
      .DATA_WIDTH(8)
  ) u_uart_tx (
      .arst_ni(datapath_rst_n),
      .clk_i  (uart_clk),

      .data_ready_o(tx_ready_in),
      .data_valid_i(tx_data_valid_masked),
      .data_i      (tx_fifo_rdata),

      .data_bits_i  (data_bits),
      .parity_en_i  (parity_en),
      .parity_type_i(parity_type),
      .extra_stop_i (stop_bits),

      .tx_o(UART_TX)
  );

  adn_uart_receiver #(
      .OVERSAMPLE(8)
  ) u_uart_rx (
      .arst_ni(datapath_rst_n),
      .clk_i  (uart_clk),

      .data_bits_i  (data_bits),
      .parity_en_i  (parity_en),
      .parity_type_i(parity_type),

      .rx_i        (UART_RX),
      .data_o      (rx_fifo_wdata),
      .data_valid_o(rx_data_valid_out)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSERTIONS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION
  initial begin
    if (DATA_WIDTH > 2) begin
      $display("\033[1;33m%m DATA_WIDTH\033[0m");
    end
  end
`endif  // SIMULATION

endmodule


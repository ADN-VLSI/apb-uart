/*
 * Module: apb_uart_top
 * Author: Ahasan Ullah Khalid
 * Brief: APB-controlled UART with asynchronous transmit and receive FIFOs.
 * Copyright (c) 2026 ADN Semiconductors
 * SPDX-License-Identifier: MIT
 */

`include "../submodule/adn_apb/include/apb/typedef.svh"

`APB_T(apb, 32, 32)

module apb_uart_top #(
    parameter int ADDR_WIDTH = 32,  // APB address width
    parameter int DATA_WIDTH = 32,  // APB data width
    parameter int FIFO_SIZE  = 4    // FIFO depth is 2**FIFO_SIZE entries
) (
    input logic PCLK,    // APB clock
    input logic PRESETn, // Active-low reset

    input  apb_req_t  apb_req_i,  // APB request
    output apb_resp_t apb_resp_o, // APB response

    output logic UART_TX,  // UART transmit
    input  logic UART_RX,  // UART receive

    output logic UART_IRQ  // UART interrupt
);

  // APB register access
  logic reg_write_en;
  logic reg_read_en;

  // UART configuration and reset control
  logic        uart_sw_rst;
  logic        datapath_rst_n;
  logic        tx_fifo_rst_n;
  logic        rx_fifo_rst_n;
  logic        tx_fifo_flush;
  logic        rx_fifo_flush;
  logic        tx_en;
  logic        rx_en;
  logic [11:0] clk_div;
  logic [3:0]  prescaler;
  logic [1:0]  data_bits;
  logic        parity_en;
  logic        parity_type;
  logic        stop_bits;

  // FIFO status
  logic [9:0]          tx_data_cnt;
  logic [9:0]          rx_data_cnt;
  logic [FIFO_SIZE:0]  tx_fifo_count;
  logic [FIFO_SIZE:0]  rx_fifo_count;
  logic                tx_fifo_empty;
  logic                tx_fifo_full;
  logic                rx_fifo_empty;
  logic                rx_fifo_full;

  // Transmit path
  logic [7:0] tx_fifo_wdata;
  logic       tx_fifo_push;
  logic       tx_fifo_ready_in;
  logic [7:0] tx_fifo_rdata;
  logic       tx_fifo_valid_out;
  logic       tx_ready_in;
  logic       tx_fifo_pop_ready;
  logic       tx_data_valid_masked;

  // Receive path
  logic [7:0] rx_fifo_wdata;
  logic       rx_data_valid_out;
  logic       rx_fifo_push;
  logic       rx_fifo_ready_in;
  logic [7:0] rx_fifo_rdata;
  logic       rx_fifo_pop;
  logic       rx_fifo_valid_out;

  // Register interface arbitration
  logic [7:0] tx_access_req_id;
  logic       tx_req_valid;
  logic       tx_grant_pop;
  logic [7:0] rx_access_req_id;
  logic       rx_req_valid;
  logic       rx_grant_pop;

  // Interrupt enables and status
  logic tx_fifo_empty_int_en;
  logic tx_fifo_full_int_en;
  logic rx_fifo_empty_int_en;
  logic rx_fifo_full_int_en;
  logic tx_empty_irq;
  logic tx_full_irq;
  logic rx_empty_irq;
  logic rx_full_irq;

  logic uart_clk;

  // APB access, reset, FIFO status, and datapath control
  assign reg_write_en = apb_req_i.psel & apb_req_i.penable & apb_req_i.pwrite;
  assign reg_read_en  = apb_req_i.psel & apb_req_i.penable & ~apb_req_i.pwrite;

  assign datapath_rst_n = PRESETn & ~uart_sw_rst;
  assign tx_fifo_rst_n  = datapath_rst_n & ~tx_fifo_flush;
  assign rx_fifo_rst_n  = datapath_rst_n & ~rx_fifo_flush;

  assign tx_fifo_full  = ~tx_fifo_ready_in;
  assign tx_fifo_empty = ~tx_fifo_valid_out;
  assign rx_fifo_full  = ~rx_fifo_ready_in;
  assign rx_fifo_empty = ~rx_fifo_valid_out;

  assign tx_data_cnt = {{(10 - FIFO_SIZE - 1) {1'b0}}, tx_fifo_count};
  assign rx_data_cnt = {{(10 - FIFO_SIZE - 1) {1'b0}}, rx_fifo_count};

  assign tx_data_valid_masked = tx_fifo_valid_out & tx_en;
  assign tx_fifo_pop_ready    = tx_ready_in & tx_en;
  assign rx_fifo_push         = rx_data_valid_out & rx_en;

  // Combine enabled FIFO status interrupts
  assign tx_empty_irq = tx_fifo_empty & tx_fifo_empty_int_en;
  assign tx_full_irq  = tx_fifo_full & tx_fifo_full_int_en;
  assign rx_empty_irq = rx_fifo_empty & rx_fifo_empty_int_en;
  assign rx_full_irq  = rx_fifo_full & rx_fifo_full_int_en;
  assign UART_IRQ     = tx_empty_irq | tx_full_irq | rx_empty_irq | rx_full_irq;

  // APB register interface
  adn_uart_register_interface #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_reg_intf (
      .clk  (PCLK),
      .rst_n(PRESETn),

      .reg_addr    (apb_req_i.paddr),
      .reg_wdata   (apb_req_i.pwdata),
      .reg_write_en(reg_write_en),
      .reg_read_en (reg_read_en),
      .reg_rdata   (apb_resp_o.prdata),
      .reg_ready   (apb_resp_o.pready),
      .reg_error   (apb_resp_o.pslverr),

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

  // Generate the UART baud clock from PCLK
  adn_clk_rst_clk_div #(
      .DIV_WIDTH(16)
  ) u_clk_div (
      .arst_ni(datapath_rst_n),
      .clk_i  (PCLK),
      .div_i  ({prescaler, clk_div}),
      .clk_o  (uart_clk)
  );

  // Cross transmit data from the APB clock domain to the UART clock domain.
  adn_common_cdc_fifo #(
      .DATA_WIDTH(8),
      .FIFO_SIZE (FIFO_SIZE)
  ) u_tx_fifo (
      .data_in_i       (tx_fifo_wdata),
      .data_in_valid_i (tx_fifo_push),
      .data_in_ready_o (tx_fifo_ready_in),
      .data_in_arst_ni (tx_fifo_rst_n),
      .data_in_clk_i   (PCLK),
      .data_in_count_o (tx_fifo_count),
      .data_out_o      (tx_fifo_rdata),
      .data_out_valid_o(tx_fifo_valid_out),
      .data_out_ready_i(tx_fifo_pop_ready),
      .data_out_arst_ni(tx_fifo_rst_n),
      .data_out_clk_i  (uart_clk),
      .data_out_count_o()
  );

  // Cross received UART data back into the APB clock domain.
  adn_common_cdc_fifo #(
      .DATA_WIDTH(8),
      .FIFO_SIZE (FIFO_SIZE)
  ) u_rx_fifo (
      .data_in_i       (rx_fifo_wdata),
      .data_in_valid_i (rx_fifo_push),
      .data_in_ready_o (rx_fifo_ready_in),
      .data_in_arst_ni (rx_fifo_rst_n),
      .data_in_clk_i   (uart_clk),
      .data_in_count_o (),
      .data_out_o      (rx_fifo_rdata),
      .data_out_valid_o(rx_fifo_valid_out),
      .data_out_ready_i(rx_fifo_pop),
      .data_out_arst_ni(rx_fifo_rst_n),
      .data_out_clk_i  (PCLK),
      .data_out_count_o(rx_fifo_count)
  );

  // Serialize transmit data
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

  // Deserialize received data
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

endmodule

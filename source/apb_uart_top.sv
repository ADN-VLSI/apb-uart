/*

@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-08-13 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | 2026-08-13 | Ahasan Ullah Khalid | Stable release                                         |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
This file is part of ADN-VLSI/apb_uart
Copyright (c) 2026 ADN Semiconductors
Licensed under the MIT License
See LICENSE file in the project root for full license information

*/

// @foez---bhai, add comments to the parameters, ports
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

  // @foez---bhai, add comments to the functional blocks, signals, and submodules

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // LOCALPARAMS GENERATED
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // TYPEDEFS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Register Bus (APB to Register Block)
  logic [ADDR_WIDTH-1:0] reg_addr;
  logic [DATA_WIDTH-1:0] reg_wdata;
  logic                  reg_write_en;
  logic                  reg_read_en;
  logic [DATA_WIDTH-1:0] reg_rdata;
  logic                  reg_ready;
  logic                  reg_error;

  // Register Block to TX FIFO
  logic [           7:0] tx_fifo_wdata;
  logic                  tx_fifo_push;
  logic                  tx_fifo_full;

  // TX FIFO to UART TX
  logic [           7:0] tx_data_out;
  logic                  tx_fifo_pop;
  logic                  tx_fifo_empty;
  logic                  tx_busy;

  // UART RX to RX FIFO
  logic [           7:0] rx_data_in;
  logic                  rx_fifo_push;
  logic                  rx_frame_error;
  logic                  rx_parity_error;

  // RX FIFO to Register Block
  logic [           7:0] rx_fifo_rdata;
  logic                  rx_fifo_pop;
  logic                  rx_fifo_empty;
  logic                  rx_fifo_full;

  // Baud Generator signals
  logic [          15:0] baud_divisor;
  logic                  baud_tick_tx;
  logic                  baud_tick_rx;

  // Interrupt Configuration & Status (from Reg Block)
  logic                  intr_enable_rx;
  logic                  intr_enable_tx;
  logic                  intr_enable_err;
  logic                  intr_clear;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSIGNMENTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SUBMODULES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // SEQUENTIALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ASSERTIONS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // INITIAL CHECKS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SIMULATION
  initial begin
    if (DATA_WIDTH > 2) begin
      $display("\033[1;33m%m DATA_WIDTH\033[0m");
    end
  end
`endif  // SIMULATION

endmodule


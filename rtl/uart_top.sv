// UART Top-Level Module
// This module integrates all UART components: APB interface, registers, FIFOs,
// clock dividers, TX and RX modules, providing a complete UART peripheral.
module uart_top
  import apb_uart_pkg::*;  // Import package with types and parameters
#(
    parameter int ADDR_WIDTH = 5,   // Address width for APB
    parameter int DATA_WIDTH = 32   // Data width for APB
) (
    input logic arst_ni,             // Asynchronous reset, active low
    input logic clk_i,               // Main clock input

    // APB Slave Interface
    input logic                      psel_i,      // Peripheral select
    input logic                      penable_i,   // Peripheral enable
    input logic [    ADDR_WIDTH-1:0] paddr_i,     // Peripheral address
    input logic                      pwrite_i,    // Peripheral write enable
    input logic [    DATA_WIDTH-1:0] pwdata_i,    // Peripheral write data
    input logic [(DATA_WIDTH/8)-1:0] pstrb_i,     // Peripheral byte strobe

    output logic                  pready_o,   // Peripheral ready
    output logic [DATA_WIDTH-1:0] prdata_o,   // Peripheral read data
    output logic                  pslverr_o,  // Peripheral slave error

    // UART Serial Interface
    input  logic rx_i,              // UART RX input
    output logic tx_o,              // UART TX output

    // Interrupt Outputs
    output logic irq_tx_almost_full,   // TX FIFO almost full interrupt
    output logic irq_rx_almost_full,   // RX FIFO almost full interrupt
    output logic irq_rx_parity_error,  // RX parity error interrupt
    output logic irq_rx_valid          // RX data valid interrupt
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Signals
  //////////////////////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////
  // APB-MEMIF
  ////////////////////////////////////////////////

  logic                                    mreq;     // Memory request
  logic               [    ADDR_WIDTH-1:0] maddr;    // Memory address
  logic                                    mwe;      // Memory write enable
  logic               [    DATA_WIDTH-1:0] mwdata;   // Memory write data
  logic               [(DATA_WIDTH/8)-1:0] mstrb;    // Memory byte strobe
  logic                                    mack;     // Memory acknowledge
  logic               [    DATA_WIDTH-1:0] mrdata;   // Memory read data
  logic                                    mresp;    // Memory response (error)

  ////////////////////////////////////////////////
  // MEMIF-REGIF
  ////////////////////////////////////////////////

  ctrl_reg_t                               ctrl_reg;       // Control register
  clk_div_reg_t                            clk_div_reg;    // Clock divider register
  cfg_reg_t                                cfg_reg;        // Configuration register

  ////////////////////////////////////////////////
  // REGIF-FIFO
  ////////////////////////////////////////////////

  tx_fifo_count_reg_t                      tx_fifo_count_reg;     // TX FIFO count
  rx_fifo_count_reg_t                      rx_fifo_count_reg;     // RX FIFO count

  tx_data_reg_t                            regif_tx_data_reg;     // TX data from regif
  logic                                    regif_tx_data_valid;   // TX data valid
  logic                                    regif_tx_data_ready;   // TX data ready

  rx_data_reg_t                            regif_rx_data_reg;     // RX data to regif
  logic                                    regif_rx_data_valid;   // RX data valid
  logic                                    regif_rx_data_ready;   // RX data ready

  ////////////////////////////////////////////////
  // FIFO-TX/RX
  ////////////////////////////////////////////////

  tx_data_reg_t                            uart_tx_data_reg;      // TX data to UART TX
  logic                                    uart_tx_data_valid;    // TX data valid
  logic                                    uart_tx_data_ready;    // TX data ready

  rx_data_reg_t                            uart_rx_data_reg;      // RX data from UART RX
  logic                                    uart_rx_data_valid;    // RX data valid
  logic                                    uart_rx_data_ready;    // RX data ready
  logic                                    uart_rx_parity_error;  // RX parity error

  logic               [    TX_FIFO_SIZE:0] tx_fifo_count_adpt;     // TX FIFO count adapter
  logic               [    RX_FIFO_SIZE:0] rx_fifo_count_adpt;     // RX FIFO count adapter

  ////////////////////////////////////////////////
  // MISCELLANEOUS
  ////////////////////////////////////////////////

  intr_ctrl_reg_t                          intr_ctrl_reg;         // Interrupt control register

  logic                                    divided_clk_n;         // Divided clock (n)
  logic                                    divided_clk_8n;        // Divided clock (8n)

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Submodule Instantiations
  //////////////////////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////
  // APB Memory Interface
  // Bridges APB bus to internal memory interface
  ////////////////////////////////////////////////

  apb_memif #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_apb_memif (
      .arst_ni(arst_ni),
      .clk_i(clk_i),
      .psel_i(psel_i),
      .penable_i(penable_i),
      .paddr_i(paddr_i),
      .pwrite_i(pwrite_i),
      .pwdata_i(pwdata_i),
      .pstrb_i(pstrb_i),
      .pready_o(pready_o),
      .prdata_o(prdata_o),
      .pslverr_o(pslverr_o),
      .mreq_o(mreq),
      .maddr_o(maddr),
      .mwe_o(mwe),
      .mwdata_o(mwdata),
      .mstrb_o(mstrb),
      .mack_i(mack),
      .mrdata_i(mrdata),
      .mresp_i(mresp)
  );

  ////////////////////////////////////////////////
  // UART Register Interface
  // Handles register reads/writes and FIFO interfacing
  ////////////////////////////////////////////////

  uart_regif #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_uart_regif (
      .arst_ni(arst_ni),
      .clk_i(clk_i),
      .mreq_i(mreq),
      .maddr_i(maddr),
      .mwe_i(mwe),
      .mwdata_i(mwdata),
      .mstrb_i(mstrb),
      .mack_o(mack),
      .mrdata_o(mrdata),
      .mresp_o(mresp),
      .ctrl_reg_o(ctrl_reg),
      .clk_div_reg_o(clk_div_reg),
      .cfg_reg_o(cfg_reg),
      .tx_fifo_count_reg_i(tx_fifo_count_reg),
      .rx_fifo_count_reg_i(rx_fifo_count_reg),
      .tx_data_reg_o(regif_tx_data_reg),
      .tx_data_valid_o(regif_tx_data_valid),
      .tx_data_ready_i(regif_tx_data_ready),
      .rx_data_reg_i(regif_rx_data_reg),
      .rx_data_valid_i(regif_rx_data_valid),
      .rx_data_ready_o(regif_rx_data_ready),
      .intr_ctrl_reg_o(intr_ctrl_reg)
  );

  ////////////////////////////////////////////////
  // TX FIFO
  // Clock domain crossing FIFO for TX data
  ////////////////////////////////////////////////

  cdc_fifo #(
      .ELEM_WIDTH(8),
      .FIFO_SIZE (TX_FIFO_SIZE)
  ) u_tx_fifo (
      .arst_ni(arst_ni),
      .elem_in_i(regif_tx_data_reg.TX_DATA),
      .elem_in_clk_i(clk_i),
      .elem_in_valid_i(regif_tx_data_valid),
      .elem_in_ready_o(regif_tx_data_ready),
      .elem_in_count_o(tx_fifo_count_adpt),
      .elem_out_o(uart_tx_data_reg.TX_DATA),
      .elem_out_clk_i(divided_clk_8n),
      .elem_out_valid_o(uart_tx_data_valid),
      .elem_out_ready_i(uart_tx_data_ready),
      .elem_out_count_o()
  );

  ////////////////////////////////////////////////
  // RX FIFO
  // Clock domain crossing FIFO for RX data
  ////////////////////////////////////////////////

  cdc_fifo #(
      .ELEM_WIDTH(8),
      .FIFO_SIZE (RX_FIFO_SIZE)
  ) u_rx_fifo (
      .arst_ni(arst_ni),
      .elem_in_i(uart_rx_data_reg.RX_DATA),
      .elem_in_clk_i(divided_clk_n),
      .elem_in_valid_i(uart_rx_data_valid),
      .elem_in_ready_o(uart_rx_data_ready),
      .elem_in_count_o(),
      .elem_out_o(regif_rx_data_reg.RX_DATA),
      .elem_out_clk_i(clk_i),
      .elem_out_valid_o(regif_rx_data_valid),
      .elem_out_ready_i(regif_rx_data_ready),
      .elem_out_count_o(rx_fifo_count_adpt)
  );

  ////////////////////////////////////////////////
  // CLK DIV n
  // Clock divider for UART baud rate (divided by n)
  ////////////////////////////////////////////////

  clk_div #(
      .DIV_WIDTH(32)
  ) u_clk_div (
      .arst_ni(arst_ni),
      .clk_i  (clk_i),
      .div_i  ((clk_div_reg>>3)),  // Divide by register value shifted
      .clk_o  (divided_clk_n)
  );

  ////////////////////////////////////////////////
  // CLK DIV 8
  // Further divide for TX bit timing (8x oversampling)
  ////////////////////////////////////////////////

  clk_div #(
      .DIV_WIDTH(4)
  ) u_clk_div_8n (
      .arst_ni(arst_ni),
      .clk_i  (divided_clk_n),
      .div_i  (4'd8),  // Fixed divide by 8
      .clk_o  (divided_clk_8n)
  );

  ////////////////////////////////////////////////
  // UART TX
  // UART transmitter module
  ////////////////////////////////////////////////

  uart_tx u_tx (
      .arst_ni(arst_ni),
      .clk_i  (divided_clk_8n),

      .data_i(uart_tx_data_reg.TX_DATA),
      .data_valid_i(uart_tx_data_valid),
      .data_ready_o(uart_tx_data_ready),

      .parity_en_i (cfg_reg.PARITY_EN),
      .extra_stop_i(cfg_reg.EXTRA_STOP_BITS),

      .tx_o(tx_o)
  );

  ////////////////////////////////////////////////
  // UART RX
  // UART receiver module
  ////////////////////////////////////////////////

  uart_rx u_rx (
      .arst_ni(arst_ni),
      .clk_i  (divided_clk_n),

      .rx_i(rx_i),

      .parity_en_i  (cfg_reg.PARITY_EN),
      .parity_type_i(cfg_reg.PARITY_TYPE),

      .data_o(uart_rx_data_reg.RX_DATA),
      .data_valid_o(uart_rx_data_valid),

      .parity_error_o(uart_rx_parity_error)
  );

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Combinational Logic
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Assign FIFO counts to registers
  assign tx_fifo_count_reg   = tx_fifo_count_adpt;
  assign rx_fifo_count_reg   = rx_fifo_count_adpt;

  ////////////////////////////////////////////////
  // Interrupt Signals
  // Generate interrupts based on register settings and conditions
  ////////////////////////////////////////////////

  assign irq_tx_almost_full  = intr_ctrl_reg.TX_ALMOST_FULL ? tx_fifo_count_reg > 200 : '0;
  assign irq_rx_almost_full  = intr_ctrl_reg.RX_ALMOST_FULL ? rx_fifo_count_reg > 200 : '0;
  assign irq_rx_parity_error = intr_ctrl_reg.RX_PARITY_ERROR ? uart_rx_parity_error : '0;
  assign irq_rx_valid        = intr_ctrl_reg.RX_VALID ? regif_rx_data_valid : '0;

endmodule

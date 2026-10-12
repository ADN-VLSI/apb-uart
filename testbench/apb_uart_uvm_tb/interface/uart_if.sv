`ifndef __GUARD_UART_IF_SV__
`define __GUARD_UART_IF_SV__ 0

interface uart_if;

  // ------------------------------------------------------------
  // UART External Signals
  // ------------------------------------------------------------

  logic UART_TX;
  logic UART_RX;
  logic UART_IRQ;

  // ------------------------------------------------------------
  // UART Monitor Clocking Block
  // ------------------------------------------------------------

  clocking monitor_cb @(posedge UART_TX);

    default input #1step;

    input UART_TX;
    input UART_RX;
    input UART_IRQ;

  endclocking : monitor_cb

  // ------------------------------------------------------------
  // UART Driver Modport
  // ------------------------------------------------------------

  modport DRIVER (
    input  UART_TX,
    input  UART_IRQ,
    output UART_RX
  );

  // ------------------------------------------------------------
  // UART Monitor Modport
  // ------------------------------------------------------------

  modport MONITOR (
    input UART_TX,
    input UART_RX,
    input UART_IRQ
  );

endinterface : uart_if

`endif
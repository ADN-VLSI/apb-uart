`ifndef __GUARD_UART_IF_SV__
`define __GUARD_UART_IF_SV__ 0

interface uart_if #(
    parameter int PCLK_PERIOD_NS = 10
)(
    input logic PCLK,
    input logic PRESETn
);

    // ------------------------------------------------------------
    // UART signals
    // ------------------------------------------------------------

    logic uart_tx;
    logic uart_rx;


    // ------------------------------------------------------------
    // Driver clocking block
    // ------------------------------------------------------------

    clocking cb_drv @(posedge PCLK);

        default input #1step output #1step;

        output uart_rx;
        input  uart_tx;

    endclocking


    // ------------------------------------------------------------
    // Monitor clocking block
    // ------------------------------------------------------------

    clocking cb_mon @(posedge PCLK);

        default input #1step output #1step;

        input uart_rx;
        input uart_tx;

    endclocking


    // ------------------------------------------------------------
    // Modports
    // ------------------------------------------------------------

    modport DRIVER (
        clocking cb_drv
    );


    modport MONITOR (
        clocking cb_mon
    );


    modport DUT (
        input  PCLK,
        input  PRESETn,

        input  uart_rx,
        output uart_tx
    );

endinterface

`endif
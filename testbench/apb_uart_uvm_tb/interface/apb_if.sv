`ifndef __GUARD_APB_IF_SV__
`define __GUARD_APB_IF_SV__ 0

interface apb_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)(
    input logic PCLK,
    input logic PRESETn
);

    // ------------------------------------------------------------
    // APB Request
    // ------------------------------------------------------------

    logic                  psel;
    logic                  penable;
    logic                  pwrite;
    logic [ADDR_WIDTH-1:0] paddr;
    logic [DATA_WIDTH-1:0] pwdata;

    // ------------------------------------------------------------
    // APB Response
    // ------------------------------------------------------------

    logic [DATA_WIDTH-1:0] prdata;
    logic                  pready;
    logic                  pslverr;


    // ------------------------------------------------------------
    // Driver clocking block
    // ------------------------------------------------------------

    clocking cb_drv @(posedge PCLK);

        default input #1step output #1step;

        output psel;
        output penable;
        output pwrite;
        output paddr;
        output pwdata;

        input  prdata;
        input  pready;
        input  pslverr;

    endclocking


    // ------------------------------------------------------------
    // Monitor clocking block
    // ------------------------------------------------------------

    clocking cb_mon @(posedge PCLK);

        default input #1step output #1step;

        input psel;
        input penable;
        input pwrite;
        input paddr;
        input pwdata;

        input prdata;
        input pready;
        input pslverr;

    endclocking


    // ------------------------------------------------------------
    // Modports
    // ------------------------------------------------------------

    modport DUT (
        input  PCLK,
        input  PRESETn,

        input  psel,
        input  penable,
        input  pwrite,
        input  paddr,
        input  pwdata,

        output prdata,
        output pready,
        output pslverr
    );


    modport DRIVER (
        clocking cb_drv
    );


    modport MONITOR (
        clocking cb_mon
    );


endinterface

`endif
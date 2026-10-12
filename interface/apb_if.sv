`ifndef __GUARD_APB_IF_SV__
`define __GUARD_APB_IF_SV__ 0

interface apb_if;

  // ------------------------------------------------------------
  // Clock and Reset
  // ------------------------------------------------------------

  logic PCLK;
  logic PRESETn;

  // ------------------------------------------------------------
  // APB Request Signals
  // ------------------------------------------------------------

  logic        psel;
  logic        penable;
  logic [31:0] paddr;
  logic [2:0]  pprot;
  logic        pwrite;
  logic [31:0] pwdata;
  logic [3:0]  pstrb;

  // ------------------------------------------------------------
  // APB Response Signals
  // ------------------------------------------------------------

  logic        pready;
  logic [31:0] prdata;
  logic        pslverr;

  // ------------------------------------------------------------
  // APB Master Clocking Block
  // ------------------------------------------------------------

  clocking cb @(posedge PCLK);

    default input #1step output #0;

    // Master-driven request signals
    output psel;
    output penable;
    output paddr;
    output pprot;
    output pwrite;
    output pwdata;
    output pstrb;

    // Slave-driven response signals
    input pready;
    input prdata;
    input pslverr;

  endclocking : cb

  // ------------------------------------------------------------
  // APB Driver Modport
  // ------------------------------------------------------------

  modport DRIVER (
    input  PCLK,
    input  PRESETn,

    output psel,
    output penable,
    output paddr,
    output pprot,
    output pwrite,
    output pwdata,
    output pstrb,

    input  pready,
    input  prdata,
    input  pslverr,

    clocking cb
  );

  // ------------------------------------------------------------
  // APB Monitor Modport
  // ------------------------------------------------------------

  modport MONITOR (
    input PCLK,
    input PRESETn,

    input psel,
    input penable,
    input paddr,
    input pprot,
    input pwrite,
    input pwdata,
    input pstrb,

    input pready,
    input prdata,
    input pslverr
  );

endinterface : apb_if

`endif
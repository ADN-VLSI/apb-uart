`ifndef __GUARD_APB_TRANSACTIONS_CG_SV__
`define __GUARD_APB_TRANSACTIONS_CG_SV__

// Coverage group for APB transactions
covergroup apb_transactions_cg with function sample(
  input bit       pwrite,
  input bit [3:0] pstrb,
  input bit [7:0] pslverr
);

  // Coverpoint for pwrite signal (Read/Write)
  coverpoint pwrite {
    bins read  = {0};
    bins write = {1};
  }

  coverpoint pstrb[0] {
    bins strobe_set = {1};
    bins strobe_clear = {0};
  }

  coverpoint pstrb[1] {
    bins strobe_set = {1};
    bins strobe_clear = {0};
  }

  coverpoint pstrb[2] {
    bins strobe_set = {1};
    bins strobe_clear = {0};
  }

  coverpoint pstrb[3] {
    bins strobe_set = {1};
    bins strobe_clear = {0};
  }

  // Coverpoint for pslverr signal (Slave Error)
  coverpoint pslverr {
    bins no_error  = {0};
    bins error     = {1};
  }

endgroup

`endif

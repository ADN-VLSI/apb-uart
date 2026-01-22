`ifndef __GUARD_TEST_STATUS_CG_SV__
`define __GUARD_TEST_STATUS_CG_SV__

// Coverage group for test status
covergroup test_status_cg with function sample(
  input bit       status
);

  coverpoint status {
    illegal_bins fail = {0};
    bins         pass = {1};
  }

endgroup

`endif

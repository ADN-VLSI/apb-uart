`ifndef __GUARD_APB_UART_PKG_SV__
`define __GUARD_APB_UART_PKG_SV__

package apb_uart_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "apb/apb_seq_item.sv"
  `include "component/apb_seq.sv"
  `include "component/apb_dvr.sv"
  `include "component/apb_agent.sv"
  `include "env/apb_uart_env.sv"
  `include "sequence/apb_reg_seq.sv"
  `include "tests/base_test.sv"
  `include "tests/basic_read_test.sv"
  `include "tests/basic_write_test.sv"
  `include "tests/all_reg_access_test.sv"
endpackage

`endif
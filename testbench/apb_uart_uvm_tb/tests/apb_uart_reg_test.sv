`ifndef __GUARD_APB_UART_REG_TEST_SV__
`define __GUARD_APB_UART_REG_TEST_SV__ 0

`include "apb_uart_top_uvm_tb/tests/apb_uart_base_test.sv"
`include "apb_uart_top_uvm_tb/seq/apb_uart_init_seq.sv"
`include "apb_uart_top_uvm_tb/seq/apb_uart_reg_rw_seq.sv"

// Register access test: write random values to the CFG register and read
// them back over APB. The scoreboard checks each read against the last write.
class apb_uart_reg_test extends apb_uart_base_test;

  `uvm_component_utils(apb_uart_reg_test)

  function new (string name = "apb_uart_reg_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task main_phase(uvm_phase phase);
    apb_uart_init_seq    init_seq;
    apb_uart_reg_rw_seq  reg_seq;

    super.main_phase(phase);
    phase.raise_objection(this);

    // Number of write/read pairs (read by apb_uart_reg_rw_seq)
    uvm_config_db#(int)::set(uvm_root::get(), "parameter", "APB_UART_REG_RW_SEQ_LENGTH", 20);

    init_seq = apb_uart_init_seq::type_id::create("init_seq");
    reg_seq  = apb_uart_reg_rw_seq::type_id::create("reg_seq");

    // 1. Bring the UART to a known state
    init_seq.start(env.apb.sqr);

    // 2. Write random values to CFG and read each one back
    reg_seq.start(env.apb.sqr);

    phase.drop_objection(this);
  endtask

endclass

`endif

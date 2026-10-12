`ifndef __GUARD_RANDOM_APB_RDATA_SEQ_SV__
`define __GUARD_RANDOM_APB_RDATA_SEQ_SV__ 0

`include "apb_uart_top_uvm_tb/obj/apb/apb_seq_item.sv"

// Sequence: read the RXD register over APB, one or more times.
// How many reads: set RANDOM_APB_RDATA_SEQ_LENGTH in the config DB (default 1).
class random_apb_rdata_seq extends uvm_sequence #(apb_seq_item);

  `uvm_object_utils(random_apb_rdata_seq)

  function new (string name = "random_apb_rdata_seq");
    super.new(name);
  endfunction

  virtual task body();
    int seq_length;

    // Number of reads (use 1 if the test did not set it)
    if (!uvm_config_db#(int)::get(uvm_root::get(), "parameter", "RANDOM_APB_RDATA_SEQ_LENGTH", seq_length)) begin
      seq_length = 1;
    end

    repeat (seq_length) begin
      `uvm_do_with(req, {we == 0; addr == ADDR_RXD;})
    end
  endtask

endclass

`endif

`ifndef __GUARD_RANDOM_APB_RDATA_SEQ_SV__
`define __GUARD_RANDOM_APB_RDATA_SEQ_SV__ 0



`include "object/apb_seq_item.sv"

class random_apb_rdata_seq extends uvm_sequence #(apb_seq_item);

  `uvm_object_utils(random_apb_rdata_seq)

  function new(string name = "random_apb_rdata_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    int seq_length;
    if (!uvm_config_db#(int)::get(
            uvm_root::get(), "parameter", "RANDOM_APB_RDATA_SEQ_LENGTH", seq_length
        ))
      seq_length = 1;
    repeat (seq_length) begin
      `uvm_do_with(req,
                   {
      req.tx_type == 0;
      req.addr == 'h18;
    })
    end
  endtask : body

endclass


`endif

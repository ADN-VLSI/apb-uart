// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_RANDOM_APB_RDATA_SEQ_SV__
`define __GUARD_RANDOM_APB_RDATA_SEQ_SV__ 0

// Include the APB sequence item class
`include "object/apb_seq_item.sv"

// Random APB Read Data Sequence
// This sequence generates random APB read transactions to a specific address ('h18).
// The sequence length can be configured via the "RANDOM_APB_RDATA_SEQ_LENGTH" parameter.
class random_apb_rdata_seq extends uvm_sequence #(apb_seq_item);

  // UVM object utilities for factory registration
  `uvm_object_utils(random_apb_rdata_seq)

  // Constructor for the random APB read data sequence
  function new(string name = "random_apb_rdata_seq");
    super.new(name);
  endfunction : new

  // Main sequence body: generates read transactions
  virtual task body();
    int seq_length;
    // Get sequence length from configuration database, default to 1
    if (!uvm_config_db#(int)::get(
            uvm_root::get(), "parameter", "RANDOM_APB_RDATA_SEQ_LENGTH", seq_length
        ))
      seq_length = 1;
    // Repeat for the specified sequence length
    repeat (seq_length) begin
      // Generate a read transaction to address 'h18
      `uvm_do_with(req,
                   {
      req.tx_type == 0;
      req.addr == 'h18;
    })
    end
  endtask : body

endclass

`endif

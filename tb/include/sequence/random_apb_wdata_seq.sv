// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_RANDOM_APB_WDATA_SEQ_SV__
`define __GUARD_RANDOM_APB_WDATA_SEQ_SV__ 0

// Include the APB sequence item class
`include "object/apb_seq_item.sv"

// Random APB Write Data Sequence
// This sequence generates random APB write transactions to a specific address ('h14).
// The data is constrained between 0 and 255. The sequence length can be configured
// via the "RANDOM_APB_WDATA_SEQ_LENGTH" parameter.
class random_apb_wdata_seq extends uvm_sequence #(apb_seq_item);

  // UVM object utilities for factory registration
  `uvm_object_utils(random_apb_wdata_seq)

  // Constructor for the random APB write data sequence
  function new(string name = "random_apb_wdata_seq");
    super.new(name);
  endfunction : new

  // Main sequence body: generates write transactions
  virtual task body();
    int seq_length;
    // Get sequence length from configuration database, default to 1
    if (!uvm_config_db#(int)::get(
            uvm_root::get(), "parameter", "RANDOM_APB_WDATA_SEQ_LENGTH", seq_length
        ))
      seq_length = 1;
    // Repeat for the specified sequence length
    repeat (seq_length) begin
      // Generate a write transaction to address 'h14 with data 0-255
      `uvm_do_with(req,
                   {
      req.tx_type == 1;
      req.addr == 'h14;
      req.data >= 0;
      req.data <= 255;
    })
    end
  endtask : body

endclass

`endif

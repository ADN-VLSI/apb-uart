// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_ALL_REG_ACCESS_SEQ_SV__
`define __GUARD_ALL_REG_ACCESS_SEQ_SV__ 0

// Include the APB sequence item class
`include "object/apb_seq_item.sv"

// UART Enable APB Sequence
// This sequence performs APB write transactions to enable and configure the UART.
// It flushes the FIFO, sets the clock divider, and enables the UART.
class all_reg_access_seq extends uvm_sequence #(apb_seq_item);

  // UVM object utilities for factory registration
  `uvm_object_utils(all_reg_access_seq)

  // Constructor for the UART enable APB sequence
  function new(string name = "all_reg_access_seq");
    super.new(name);
  endfunction : new

  // Main sequence body: performs UART enable and configuration
  virtual task body();
    int seq_length;
    // Get sequence length from configuration database, default to 1
    if (!uvm_config_db#(int)::get(
            uvm_root::get(), "parameter", "RANDOM_ACCESS_LEN", seq_length
        ))
      seq_length = 1;

    begin
      `uvm_do_with(req, {req.addr == 'h00; req.tx_type == 1; req.data[0] == '0;})
      `uvm_do_with(req, {req.addr == 'h00; req.tx_type == 0;})
      `uvm_do_with(req, {req.addr == 'h04; req.tx_type == 1;})
      `uvm_do_with(req, {req.addr == 'h04; req.tx_type == 0;})
      `uvm_do_with(req, {req.addr == 'h08; req.tx_type == 1;})
      `uvm_do_with(req, {req.addr == 'h08; req.tx_type == 0;})
      `uvm_do_with(req, {req.addr == 'h0C; req.tx_type == 0;})
      `uvm_do_with(req, {req.addr == 'h10; req.tx_type == 0;})
      `uvm_do_with(req, {req.addr == 'h14; req.tx_type == 1;})
      `uvm_do_with(req, {req.addr == 'h18; req.tx_type == 0;})
      `uvm_do_with(req, {req.addr == 'h1C; req.tx_type == 1;})
      `uvm_do_with(req, {req.addr == 'h1C; req.tx_type == 0;})
    end

    repeat (seq_length) begin
      `uvm_do_with(req, {if (req.addr==0) req.data[0] == '0;})
    end

  endtask : body

endclass

`endif

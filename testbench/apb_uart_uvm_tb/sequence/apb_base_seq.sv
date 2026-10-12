`ifndef __GUARD_APB_BASE_SEQ_SV__
`define __GUARD_APB_BASE_SEQ_SV__ 0

`include "apb_seq_item.sv"

import uart_reg_if_pkg::*;

class apb_base_seq extends uvm_sequence #(apb_seq_item);

  `uvm_object_utils(apb_base_seq)

  // Constructor
  function new(string name = "apb_base_seq");
    super.new(name);
  endfunction

  // ------------------------------------------------------------
  // APB WRITE TASK
  // ------------------------------------------------------------

  virtual task apb_write(
    input logic [31:0] byte_addr,
    input logic [31:0] write_data
  );

    apb_seq_item req;

    req = apb_seq_item::type_id::create("req");

    start_item(req);

    if (!req.randomize() with {
      we   == 1'b1;
      addr == byte_addr;
      data == write_data;
    }) begin
      `uvm_fatal("APB_WRITE", "Failed to randomize APB write transaction")
    end

    `uvm_info(
      get_type_name(),
      $sformatf("APB WRITE: %s", req.to_string()),
      UVM_MEDIUM
    )

    finish_item(req);

  endtask : apb_write

  // ------------------------------------------------------------
  // APB READ TASK
  // ------------------------------------------------------------

  virtual task apb_read(
    input logic [31:0] byte_addr
  );

    apb_seq_item req;

    req = apb_seq_item::type_id::create("req");

    start_item(req);

    if (!req.randomize() with {
      we   == 1'b0;
      addr == byte_addr;
    }) begin
      `uvm_fatal("APB_READ", "Failed to randomize APB read transaction")
    end

    `uvm_info(
      get_type_name(),
      $sformatf("APB READ: %s", req.to_string()),
      UVM_MEDIUM
    )

    finish_item(req);

  endtask : apb_read

endclass

`endif
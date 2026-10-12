`ifndef __GUARD_UART_BASE_SEQ_SV__
`define __GUARD_UART_BASE_SEQ_SV__ 0

`include "uart_seq_item.sv"

class uart_base_seq extends uvm_sequence #(uart_seq_item);

  `uvm_object_utils(uart_base_seq)

  function new(string name = "uart_base_seq");
    super.new(name);
  endfunction

  // ------------------------------------------------------------
  // Send UART Frame
  // ------------------------------------------------------------

  virtual task send_uart_frame(
    input logic [7:0] data,
    input int         baud_rate   = 115200,
    input bit         parity_en   = 0,
    input bit         parity_type = 0,
    input bit         extra_stop  = 0,
    input int         data_bits   = 8
  );

    uart_seq_item req;

    req = uart_seq_item::type_id::create("req");

    start_item(req);

    if (!req.randomize() with {
      data        == local::data;
      baud_rate   == local::baud_rate;
      parity_en   == local::parity_en;
      parity_type == local::parity_type;
      extra_stop  == local::extra_stop;
      data_bits   == local::data_bits;
    }) begin
      `uvm_fatal(get_type_name(), "Failed to randomize UART frame")
    end

    `uvm_info(
      get_type_name(),
      $sformatf("UART FRAME: %s", req.to_string()),
      UVM_MEDIUM
    )

    finish_item(req);

  endtask : send_uart_frame

endclass

`endif
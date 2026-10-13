`ifndef __GUARD_UART_DRIVER_SV__
`define __GUARD_UART_DRIVER_SV__ 0

`include "apb_uart_uvm_tb/object/uart_seq_item.sv"

class uart_driver extends uvm_driver #(uart_seq_item);

  `uvm_component_utils(uart_driver)

  // Virtual interface used to drive the UART signals
  virtual uart_if intf;

  function new (string name = "uart_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Get the virtual interface from the config DB
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "intf", intf)) begin
      `uvm_fatal("NOVIF", "Virtual interface not found for uart_driver")
    end
  endfunction

  // Take items from the sequencer and send them one by one
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);

      phase.raise_objection(this);
      intf.send(
        req.data,
        req.baud_rate,
        req.parity_en,
        req.parity_type,
        req.extra_stop,
        req.data_bits
      );
      phase.drop_objection(this);

      seq_item_port.item_done();
    end
  endtask

endclass

`endif

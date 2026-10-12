`ifndef __GUARD_APB_DRIVER_SV__
`define __GUARD_APB_DRIVER_SV__ 0

`include "testbench/apb_uart_uvm_tb/object/apb_seq_item.sv"

class apb_driver extends uvm_driver #(apb_seq_item);

  `uvm_component_utils(apb_driver)

  // Virtual interface used to drive the APB signals
  virtual apb_if intf;

  function new (string name = "apb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Get the virtual interface from the config DB
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "intf", intf)) begin
      `uvm_fatal("NOVIF", "Virtual interface not found for apb_driver")
    end
  endfunction

  // Take items from the sequencer and drive them one by one
  virtual task run_phase(uvm_phase phase);
    int rdata;
    int resp;

    forever begin
      seq_item_port.get_next_item(req);

      phase.raise_objection(this);
      intf.do_transaction(req.addr, req.we, req.data, rdata, resp);
      phase.drop_objection(this);

      seq_item_port.item_done();
    end
  endtask

endclass

`endif

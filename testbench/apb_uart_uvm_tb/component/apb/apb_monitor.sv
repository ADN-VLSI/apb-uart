`ifndef __GUARD_APB_MONITOR_SV__
`define __GUARD_APB_MONITOR_SV__ 0

`include "testbench/apb_uart_uvm_tb/object/apb_resp_item.sv"

class apb_monitor extends uvm_monitor;

  `uvm_component_utils(apb_monitor)

  // Analysis port: sends every observed transaction to the agent/scoreboard
  uvm_analysis_port #(apb_rsp_item) ap;

  // Virtual interface used to watch the APB signals
  virtual apb_if intf;

  function new (string name = "apb_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "intf", intf)) begin
      `uvm_fatal("NOVIF", "Virtual interface not found for apb_monitor")
    end
  endfunction

  // Watch the bus forever and publish each transaction
  virtual task run_phase(uvm_phase phase);
    apb_rsp_item item;

    forever begin
      item = apb_rsp_item::type_id::create("item");
      intf.get_transaction(item.addr, item.we, item.data, item.slverr);
      ap.write(item);
    end
  endtask

endclass

`endif

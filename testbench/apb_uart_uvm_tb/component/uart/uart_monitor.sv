`ifndef __GUARD_UART_MONITOR_SV__
`define __GUARD_UART_MONITOR_SV__ 0

`include "apb_uart_uvm_tb/object/uart_resp_item.sv"

class uart_monitor extends uvm_monitor;

  `uvm_component_utils(uart_monitor)

  // Analysis port: sends every observed UART frame to the agent/scoreboard
  uvm_analysis_port #(uart_resp_item) ap;

  // Virtual interface used to watch the UART signals
  virtual uart_if intf;

  function new (string name = "uart_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "intf", intf)) begin
      `uvm_fatal("NOVIF", "Virtual interface not found for uart_monitor")
    end
  endfunction

  // Read the UART settings (baud rate, parity, stop bits, data bits)
  // from the config DB and store them in the interface.
  // If a setting was not set in the config DB, the interface keeps its value.
  virtual task set_config();
    void'(uvm_config_db#(int)::get(null, "", "uart_baud_rate",   intf.baud_rate));
    void'(uvm_config_db#(bit)::get(null, "", "uart_parity_en",   intf.parity_en));
    void'(uvm_config_db#(bit)::get(null, "", "uart_parity_type", intf.parity_type));
    void'(uvm_config_db#(bit)::get(null, "", "uart_extra_stop",  intf.extra_stop));
    void'(uvm_config_db#(int)::get(null, "", "uart_data_bits",   intf.data_bits));
  endtask

  // Watch the UART line forever and publish each received frame
  virtual task run_phase(uvm_phase phase);
    uart_resp_item item;

    set_config();

    forever begin
      item = uart_resp_item::type_id::create("item");
      intf.recv(item.data, item.parity);

      // Record the settings that were used for this frame
      item.baud_rate   = intf.baud_rate;
      item.parity_en   = intf.parity_en;
      item.parity_type = intf.parity_type;
      item.extra_stop  = intf.extra_stop;
      item.data_bits   = intf.data_bits;

      ap.write(item);
    end
  endtask

endclass

`endif

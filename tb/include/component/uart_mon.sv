// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_UART_MON_SV__
`define __GUARD_UART_MON_SV__ 0

// Include the UART response item class
`include "object/uart_rsp_item.sv"

// UART Monitor
// This UVM monitor observes UART TX and RX transactions on the virtual interface
// and broadcasts them via an analysis port.
class uart_mon extends uvm_monitor;

  // UVM component utilities for factory registration
  `uvm_component_utils(uart_mon)

  // UART configuration parameters
  int baud_rate;
  bit parity_enable;
  bit parity_type;
  bit second_stop_bit;
  int data_bits;

  // Virtual interface to the UART DUT
  virtual uart_if vif;
  // Analysis port for sending observed transactions
  uvm_analysis_port #(uart_rsp_item) ap;

  // Constructor for the UART monitor
  function new(string name = "uart_mon", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase: create the analysis port
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
  endfunction : build_phase

  // Connect phase: retrieve the virtual interface from configuration
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual uart_if)::get(uvm_root::get(), "uart", "uart_intf", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface must be set for: %s", get_full_name()))
    end
  endfunction

  // Run phase: monitor TX and RX transactions
  task run_phase(uvm_phase phase);
    uart_rsp_item rsp_tx;
    uart_rsp_item rsp_rx;
    fork
      // Monitor TX transactions
      forever begin
        `uvm_info(get_type_name(), "UART Monitor waiting for TX data...", UVM_DEBUG)
        rsp_tx = uart_rsp_item::type_id::create("rsp_tx");
        @(negedge vif.tx);
        set_config();
        vif.recv_tx(rsp_tx.data, baud_rate, parity_enable, parity_type, second_stop_bit, data_bits);
        rsp_tx.direction = 0;  // TX direction
        ap.write(rsp_tx);
        `uvm_info(get_type_name(), $sformatf("UART TX Data Received: 0x%0h", rsp_tx.data),
                  UVM_DEBUG)
      end
      // Monitor RX transactions
      forever begin
        `uvm_info(get_type_name(), "UART Monitor waiting for RX data...", UVM_DEBUG)
        rsp_rx = uart_rsp_item::type_id::create("rsp_rx");
        @(negedge vif.rx);
        set_config();
        vif.recv_rx(rsp_rx.data, baud_rate, parity_enable, parity_type, second_stop_bit, data_bits);
        rsp_rx.direction = 1;  // RX direction
        ap.write(rsp_rx);
        `uvm_info(get_type_name(), $sformatf("UART RX Data Received: 0x%0h", rsp_rx.data),
                  UVM_DEBUG)
      end
    join
  endtask

  // Task to retrieve UART configuration from the database
  task set_config();
    void'(uvm_config_db#(int)::get(uvm_root::get(), "uart", "baud_rate", baud_rate));
    void'(uvm_config_db#(bit)::get(uvm_root::get(), "uart", "parity_enable", parity_enable));
    void'(uvm_config_db#(bit)::get(uvm_root::get(), "uart", "parity_type", parity_type));
    void'(uvm_config_db#(bit)::get(uvm_root::get(), "uart", "second_stop_bit", second_stop_bit));
    void'(uvm_config_db#(int)::get(uvm_root::get(), "uart", "data_bits", data_bits));
  endtask

endclass

`endif

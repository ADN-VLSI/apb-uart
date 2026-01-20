// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_UART_DVR_SV__
`define __GUARD_UART_DVR_SV__ 0

// Include the UART sequence item class
`include "object/uart_seq_item.sv"

// UART Driver
// This UVM driver drives UART transactions on the virtual interface.
// It sends data for transmission.
class uart_dvr extends uvm_driver #(uart_seq_item);

  // UVM component utilities for factory registration
  `uvm_component_utils(uart_dvr)

  // Virtual interface to the UART DUT
  virtual uart_if vif;

  // Constructor for the UART driver
  function new(string name = "uart_dvr", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Connect phase: retrieve the virtual interface from configuration
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual uart_if)::get(uvm_root::get(), "uart", "uart_intf", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface must be set for: %s", get_full_name()))
    end
  endfunction

  // Run phase: drive transactions on the interface
  task run_phase(uvm_phase phase);
    uart_seq_item req;
    forever begin
      // Get the next sequence item from the sequencer
      seq_item_port.get_next_item(req);
      // Log the data being transmitted
      `uvm_info(get_type_name(), $sformatf("Transmitting data: 0x%0h", req.data), UVM_HIGH)
      // Send the data via the virtual interface
      vif.send_tx(req.data);
      // Indicate completion of the item
      seq_item_port.item_done();
    end
  endtask

endclass

`endif

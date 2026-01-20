// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_APB_DVR_SV__
`define __GUARD_APB_DVR_SV__ 0

// Include the APB sequence item class
`include "object/apb_seq_item.sv"

// APB Driver
// This UVM driver drives APB transactions on the virtual interface.
// It handles read and write operations based on the sequence item.
class apb_dvr extends uvm_driver #(apb_seq_item);

  // UVM component utilities for factory registration
  `uvm_component_utils(apb_dvr)

  // Virtual interface to the APB DUT
  virtual apb_if vif;

  // Constructor for the APB driver
  function new(string name = "apb_dvr", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Connect phase: retrieve the virtual interface from configuration
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(uvm_root::get(), "apb", "apb_intf", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface must be set for: %s", get_full_name()))
    end
  endfunction

  // Run phase: drive transactions on the interface
  task run_phase(uvm_phase phase);
    apb_seq_item req;
    forever begin
      // Get the next sequence item from the sequencer
      seq_item_port.get_next_item(req);
      // Perform read or write based on transaction type
      if(req.tx_type == 0) begin
        int read_data;
        vif.read(req.addr, read_data);
      end else if(req.tx_type == 1) begin
        vif.write(req.addr, req.data);
      end
      // Indicate completion of the item
      seq_item_port.item_done();
    end
  endtask

endclass

`endif

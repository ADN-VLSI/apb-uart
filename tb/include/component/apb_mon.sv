// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_APB_MON_SV__
`define __GUARD_APB_MON_SV__ 0

// Include the APB response item class
`include "object/apb_rsp_item.sv"

// APB Monitor
// This UVM monitor observes APB transactions on the virtual interface
// and broadcasts them via an analysis port.
class apb_mon extends uvm_monitor;

  // UVM component utilities for factory registration
  `uvm_component_utils(apb_mon)

  // Virtual interface to the APB DUT
  virtual apb_if vif;
  // Analysis port for sending observed transactions
  uvm_analysis_port #(apb_rsp_item) ap;

  // Constructor for the APB monitor
  function new(string name = "apb_mon", uvm_component parent = null);
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
    if (!uvm_config_db#(virtual apb_if)::get(uvm_root::get(), "apb", "apb_intf", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface must be set for: %s", get_full_name()))
    end
  endfunction

  // Run phase: monitor transactions and send to analysis port
  task run_phase(uvm_phase phase);
    apb_rsp_item rsp;
    int direction;
    int address;
    int write_data;
    int write_strobe;
    int read_data;
    int slverr;

    forever begin
      // Get the next transaction from the interface
      vif.get_transaction(direction, address, write_data, write_strobe, read_data, slverr);
      // Create a response item and populate its fields
      rsp = apb_rsp_item::type_id::create("rsp");
      rsp.paddr   = address;
      rsp.pwrite  = direction;
      rsp.pwdata  = write_data;
      rsp.pstrb   = write_strobe;
      rsp.prdata  = read_data;
      rsp.pslverr = slverr;
      // Send the response item via the analysis port
      ap.write(rsp);
    end
  endtask

endclass

`endif

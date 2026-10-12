`ifndef __GUARD_APB_AGENT_SV__
`define __GUARD_APB_AGENT_SV__ 0

class apb_agent extends uvm_agent;

  // ------------------------------------------------------------
  // UVM Component Registration
  // ------------------------------------------------------------

  `uvm_component_utils(apb_agent)

  // ------------------------------------------------------------
  // Agent Components
  // ------------------------------------------------------------

  apb_sequencer sequencer;
  apb_driver    driver;
  apb_monitor   monitor;

  // ------------------------------------------------------------
  // Virtual Interface
  // ------------------------------------------------------------

  virtual apb_if vif;

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(string name = "apb_agent",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // ------------------------------------------------------------
  // Build Phase
  // ------------------------------------------------------------

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the APB interface.
    if (!uvm_config_db#(virtual apb_if)::get(
          this, "", "vif", vif
        )) begin
      `uvm_fatal(
        get_type_name(),
        "APB virtual interface was not configured"
      )
    end

    // The monitor is required in both active and passive modes.
    monitor = apb_monitor::type_id::create(
      "monitor", this
    );

    // Active agent components.
    if (get_is_active() == UVM_ACTIVE) begin

      sequencer = apb_sequencer::type_id::create(
        "sequencer", this
      );

      driver = apb_driver::type_id::create(
        "driver", this
      );

    end

  endfunction : build_phase

  // ------------------------------------------------------------
  // Connect Phase
  // ------------------------------------------------------------

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (get_is_active() == UVM_ACTIVE) begin

      // Connect sequence-item communication.
      driver.seq_item_port.connect(
        sequencer.seq_item_export
      );

    end

  endfunction : connect_phase

endclass : apb_agent

`endif
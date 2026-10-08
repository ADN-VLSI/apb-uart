//------------------------------------------------------------------------------
// APB Agent
// Wraps the sequencer, driver and monitor for the APB interface.
// - Active  : sequencer + driver + monitor (drives and observes the bus)
// - Passive : monitor only (observes the bus without driving it)
//------------------------------------------------------------------------------
class apb_agent extends uvm_agent;

  // Register the class with the UVM factory (enables type_id::create and overrides)
  `uvm_component_utils(apb_agent)

  //----------------------------------------------------------------------------
  // Component handles
  //----------------------------------------------------------------------------
  uvm_sequencer #(apb_seq_item) sequencer;  // Passes seq items from sequence to driver
  apb_driver                    driver;     // Converts seq items to APB pin activity
  apb_monitor                   monitor;    // Samples APB pins and builds transactions

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);                // Place this component in the UVM hierarchy
  endfunction

  //----------------------------------------------------------------------------
  // Build phase: create the child components
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Monitor is always created (needed in both active and passive modes)
    monitor = apb_monitor::type_id::create("monitor", this);

    // Sequencer and driver are created only in active mode
    if (is_active == UVM_ACTIVE) begin
      sequencer = uvm_sequencer#(apb_seq_item)::type_id::create("sequencer", this);
      driver    = apb_driver::type_id::create("driver", this);
    end
  endfunction

  //----------------------------------------------------------------------------
  // Connect phase: link the driver to the sequencer
  //----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Driver pulls items from the sequencer (get_next_item / item_done)
    if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction

endclass
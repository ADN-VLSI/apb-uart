//------------------------------------------------------------------------------
// APB-UART Base Test
// Top of the UVM class hierarchy for this testbench. Creates the environment
// and provides a reusable helper task (apb_write). Other tests, such as
// apb_uart_write_test, can extend this class and override run_phase.
//------------------------------------------------------------------------------
class apb_uart_base_test extends uvm_test;

  // Register the class with the UVM factory
  `uvm_component_utils(apb_uart_base_test)

  //----------------------------------------------------------------------------
  // Handles
  //----------------------------------------------------------------------------
  apb_uart_env env;                         // Environment holding agents and scoreboard

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);                // Place this component in the UVM hierarchy
  endfunction

  //----------------------------------------------------------------------------
  // Build phase: create the environment
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_uart_env::type_id::create("env", this);
  endfunction

  //----------------------------------------------------------------------------
  // Helper task: perform one APB register write
  //----------------------------------------------------------------------------
  task apb_write(bit [31:0] addr, bit [31:0] data);
    apb_write_seq seq = apb_write_seq::type_id::create("apb_write_seq");

    seq.addr = addr;                        // Target register address
    seq.data = data;                        // Value to write
    seq.start(env.apb.sequencer);           // Run the sequence on the APB sequencer
  endtask

  //----------------------------------------------------------------------------
  // Run phase: minimal bring-up sequence
  //----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);            // Keep the simulation alive while we work

    #200ns;                                 // Wait for reset to finish / DUT to settle
    apb_write(0, 'h8);                      // Write 0x8 to address 0x000 (CTRL register)

    phase.drop_objection(this);             // Allow the simulation to end
  endtask

endclass
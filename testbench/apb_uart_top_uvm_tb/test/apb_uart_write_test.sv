//------------------------------------------------------------------------------
// APB-UART Write Test
// Verifies the DUT transmit path. The test configures the UART over APB, then
// writes one byte to the TXD register. The DUT should serialize that byte on
// its TX line, where uart_monitor decodes it and the scoreboard compares it
// with the byte written over APB (APB TXD write -> UART TX line).
//------------------------------------------------------------------------------
class apb_uart_write_test extends apb_uart_base_test;

  // Register the class with the UVM factory
  `uvm_component_utils(apb_uart_write_test)

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);                // Place this component in the UVM hierarchy
  endfunction

  //----------------------------------------------------------------------------
  // Run phase: configure the DUT, transmit one byte, wait for it to finish
  //----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);            // Keep the simulation alive while we work

    #200ns;                                 // Wait for reset to finish / DUT to settle

    apb_write('h000, 'h8);                  // CTRL register: enable TX
    apb_write('h004, 'h0003_28b1);          // CFG register: 8 data bits, no parity, 1 stop,
                                            //   ~9600 baud at 100 MHz PCLK
    apb_write('h01c, 'h0000_005a);          // TXD register: transmit 0x5A

    #2ms;                                   // Wait for the full frame (~1.04 ms) to appear on TX

    phase.drop_objection(this);             // Allow the simulation to end
  endtask

endclass
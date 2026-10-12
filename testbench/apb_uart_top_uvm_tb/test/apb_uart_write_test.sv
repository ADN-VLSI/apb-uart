//------------------------------------------------------------------------------
// APB-UART Write Test: APB TXD write must appear as the same UART TX byte.
//------------------------------------------------------------------------------
class apb_uart_write_test extends apb_uart_base_test;

  `uvm_component_utils(apb_uart_write_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    bit passed;
    phase.raise_objection(this);
    #200ns;
    run_tx_case(passed);
    record_test_case("UART TX write", passed);
    phase.drop_objection(this);
  endtask

endclass

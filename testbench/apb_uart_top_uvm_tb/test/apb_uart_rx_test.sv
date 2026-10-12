//------------------------------------------------------------------------------
// APB-UART RX Test: UART RX bytes must be readable from the APB RXD register.
//------------------------------------------------------------------------------
class apb_uart_rx_test extends apb_uart_base_test;

  `uvm_component_utils(apb_uart_rx_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    bit passed;
    phase.raise_objection(this);
    #200ns;
    run_rx_case(passed);
    record_test_case("UART RX readback (00, 5A, FF)", passed);
    phase.drop_objection(this);
  endtask

endclass

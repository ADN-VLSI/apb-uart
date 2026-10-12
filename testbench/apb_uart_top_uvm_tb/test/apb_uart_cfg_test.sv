//------------------------------------------------------------------------------
// APB-UART Configuration Test: verify CFG register APB write/readback.
//------------------------------------------------------------------------------
class apb_uart_cfg_test extends apb_uart_base_test;

  `uvm_component_utils(apb_uart_cfg_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    bit passed;
    phase.raise_objection(this);
    #200ns;
    run_cfg_case(passed);
    record_test_case("CFG register readback", passed);
    phase.drop_objection(this);
  endtask

endclass

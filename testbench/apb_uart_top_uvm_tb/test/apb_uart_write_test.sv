class apb_uart_write_test extends apb_uart_base_test;
  `uvm_component_utils(apb_uart_write_test)
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  task run_phase(uvm_phase phase);
    phase.raise_objection(this); #200ns;
    apb_write('h000,'h8);             // Enable TX.
    apb_write('h004,'h0003_28b1);     // 8 data bits, no parity, 1 stop, ~9600 baud at 100 MHz PCLK.
    apb_write('h01c,'h0000_005a);     // Transmit 0x5A.
    #2ms; phase.drop_objection(this);
  endtask
endclass

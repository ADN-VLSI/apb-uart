class apb_uart_env extends uvm_env;
  `uvm_component_utils(apb_uart_env)
  apb_agent apb; uart_agent uart; apb_uart_scbd scbd;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); apb=apb_agent::type_id::create("apb",this); uart=uart_agent::type_id::create("uart",this); scbd=apb_uart_scbd::type_id::create("scbd",this); endfunction
  function void connect_phase(uvm_phase phase); super.connect_phase(phase); apb.monitor.ap.connect(scbd.apb_imp); uart.monitor.ap.connect(scbd.uart_tx_imp); uart.driver.rx_ap.connect(scbd.uart_rx_imp); endfunction
endclass

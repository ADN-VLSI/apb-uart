class apb_uart_env extends uvm_env;
  `uvm_component_utils(apb_uart_env)
  apb_agent apb;
  uart_agent uart;
  apb_uart_scoreboard sb;\n  apb_uart_coverage cov;
  function new(string name="apb_uart_env", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb=apb_agent::type_id::create("apb",this);
    uart=uart_agent::type_id::create("uart",this);
    sb=apb_uart_scoreboard::type_id::create("sb",this);\n    cov=apb_uart_coverage::type_id::create("cov",this);
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    uart.mon.ap.connect(sb.uart_imp);\n    apb.mon.ap.connect(cov.analysis_export);
  endfunction
endclass
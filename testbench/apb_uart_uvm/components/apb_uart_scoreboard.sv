class apb_uart_scoreboard extends uvm_component;
  `uvm_component_utils(apb_uart_scoreboard)
  uvm_analysis_imp #(uart_rsp_item,apb_uart_scoreboard) uart_imp;
  int unsigned tx_frames_seen;
  function new(string name="apb_uart_scoreboard", uvm_component parent=null);
    super.new(name,parent); 
    uart_imp=new("uart_imp",this);
  endfunction
  function void write(uart_rsp_item tr);
    tx_frames_seen++;
    `uvm_info("UART_SB",$sformatf("Observed TX frame data=0x%02h framing_error=%0b",tr.data,tr.framing_error),UVM_MEDIUM)
    if (tr.framing_error)
      `uvm_error("UART_SB","TX stop bit was not high")
  endfunction
  function void report_phase(uvm_phase phase);
    `uvm_info("UART_SB",$sformatf("TX frames observed: %0d",tx_frames_seen),UVM_LOW)
  endfunction
endclass
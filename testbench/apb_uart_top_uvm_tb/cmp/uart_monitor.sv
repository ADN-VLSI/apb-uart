class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)
  localparam int UART_BAUD=9600;
  virtual adn_uart_if vif; uvm_analysis_port #(uart_rsp_item) ap;
  function new(string name,uvm_component parent); super.new(name,parent); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); if(!uvm_config_db#(virtual adn_uart_if)::get(this,"","uart_vif",vif)) `uvm_fatal("NOVIF","uart_vif missing") endfunction
  task run_phase(uvm_phase phase); uart_rsp_item t; bit [7:0] b; time bit_time; forever begin
    @(negedge vif.line);
    if (vif.drive_enable) continue;
    bit_time=1s/UART_BAUD;

    // Confirm the line is still low at the start-bit midpoint. This rejects
    // glitches and falling data edges before they can be decoded as a frame.
    #(bit_time/2);
    if (vif.line !== 1'b0) continue;

    // The next midpoint is the center of data bit 0; sample LSB first.
    for(int i=0;i<8;i++) begin #(bit_time); b[i]=vif.line; end
    #(bit_time); t=uart_rsp_item::type_id::create("t",this); t.data=b; t.framing_error=!vif.line; ap.write(t);
  end endtask
endclass

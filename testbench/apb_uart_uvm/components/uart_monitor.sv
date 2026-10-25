class uart_monitor extends uvm_component;
  `uvm_component_utils(uart_monitor)
  virtual apb_uart_if vif;
  uvm_analysis_port #(uart_rsp_item) ap;
  int unsigned clocks_per_bit=16;

  function new(string name="uart_monitor", uvm_component parent=null);
    super.new(name,parent); 
    ap=new("ap",this);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_uart_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","uart_monitor: virtual interface not set")
    void'(uvm_config_db#(int unsigned)::get(this,"","clocks_per_bit",clocks_per_bit));
  endfunction

  // Lightweight TX pin decoder for default 8-N-1 monitoring.
  task run_phase(uvm_phase phase);
    uart_rsp_item tr;
    logic [7:0] data;
    forever begin
      @(negedge vif.UART_TX);
      if (vif.PRESETn) begin
        repeat (clocks_per_bit + (clocks_per_bit/2)) @(posedge vif.PCLK);
        for (int i=0;i<8;i++) begin
          data[i]=vif.UART_TX;
          repeat (clocks_per_bit) @(posedge vif.PCLK);
        end
        tr=uart_rsp_item::type_id::create("tr");
        tr.data=data; tr.parity_error=0; tr.framing_error=(vif.UART_TX !== 1'b1);
        ap.write(tr);
      end
    end
  endtask
endclass


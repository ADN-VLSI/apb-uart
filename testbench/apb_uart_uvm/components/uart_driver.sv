class uart_driver extends uvm_driver #(uart_seq_item);
  `uvm_component_utils(uart_driver)
  virtual apb_uart_if vif;
  int unsigned clocks_per_bit=16;

  function new(string name="uart_driver", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_uart_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","uart_driver: virtual interface not set")
    void'(uvm_config_db#(int unsigned)::get(this,"","clocks_per_bit",clocks_per_bit));
  endfunction

  task run_phase(uvm_phase phase);
    uart_seq_item req;
    vif.UART_RX <= 1'b1;
    forever begin
      seq_item_port.get_next_item(req);
      send_frame(req);
      seq_item_port.item_done();
    end
  endtask

  task automatic bit_time();
    repeat (clocks_per_bit) @(negedge vif.PCLK);
  endtask

  task automatic send_frame(uart_seq_item tr);
    int nbits;
    nbits=5+int'(tr.data_bits);
    // Keep line idle before the start bit.
    vif.UART_RX <= 1'b1;
    bit_time();
    vif.UART_RX <= 1'b0;
    bit_time();
    for (int i=0;i<nbits;i++) begin
      vif.UART_RX <= tr.data[i];
      bit_time();
    end
    if (tr.parity_en) begin
      // Even parity bit is XOR of data bits; odd parity is its inverse.
      vif.UART_RX <= (^tr.data[nbits-1:0]) ^ tr.parity_type;
      bit_time();
    end
    vif.UART_RX <= 1'b1;
    bit_time();
    if (tr.stop_bits) bit_time();
    // Inter-frame idle.
    vif.UART_RX <= 1'b1;
    bit_time();
  endtask
endclass
class uart_driver extends uvm_driver #(uart_seq_item);
  `uvm_component_utils(uart_driver)
  virtual adn_uart_if vif;
  uvm_analysis_port #(uart_rsp_item) rx_ap;
  function new(string name,uvm_component parent); super.new(name,parent); rx_ap=new("rx_ap",this); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); if(!uvm_config_db#(virtual adn_uart_if)::get(this,"","uart_vif",vif)) `uvm_fatal("NOVIF","uart_vif missing") endfunction
  task run_phase(uvm_phase phase); uart_seq_item r; uart_rsp_item observed; vif.drive_enable=0; forever begin
    seq_item_port.get_next_item(r); vif.send(r.data,r.baud);
    observed=uart_rsp_item::type_id::create("observed"); observed.data=r.data; rx_ap.write(observed);
    seq_item_port.item_done();
  end endtask
endclass

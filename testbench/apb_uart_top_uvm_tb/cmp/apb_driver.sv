class apb_driver extends uvm_driver #(apb_seq_item);
  `uvm_component_utils(apb_driver)
  virtual adn_apb_if vif;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); if(!uvm_config_db#(virtual adn_apb_if)::get(this,"","apb_vif",vif)) `uvm_fatal("NOVIF","apb_vif missing") endfunction
  task run_phase(uvm_phase phase);
    apb_seq_item r;
    forever begin
      seq_item_port.get_next_item(r);
      @(vif.driver_cb); vif.driver_cb.psel<=1; vif.driver_cb.penable<=0;
      vif.driver_cb.pwrite<=r.write; vif.driver_cb.paddr<=r.addr; vif.driver_cb.pwdata<=r.data; vif.driver_cb.pstrb<=4'hf; vif.driver_cb.pprot<=0;
      @(vif.driver_cb); vif.driver_cb.penable<=1;
      do @(vif.driver_cb); while(!vif.driver_cb.pready);
      r.rdata=vif.driver_cb.prdata; r.error=vif.driver_cb.pslverr;
      vif.driver_cb.psel<=0; vif.driver_cb.penable<=0; seq_item_port.item_done();
    end
  endtask
endclass

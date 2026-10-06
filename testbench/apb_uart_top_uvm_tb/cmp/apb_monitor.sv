class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)
  virtual adn_apb_if vif; uvm_analysis_port #(apb_rsp_item) ap;
  function new(string name,uvm_component parent); super.new(name,parent); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); if(!uvm_config_db#(virtual adn_apb_if)::get(this,"","apb_vif",vif)) `uvm_fatal("NOVIF","apb_vif missing") endfunction
  task run_phase(uvm_phase phase); apb_rsp_item t; forever begin
    @(vif.monitor_cb);
    if(vif.monitor_cb.presetn && vif.monitor_cb.psel && vif.monitor_cb.penable && vif.monitor_cb.pready) begin
      t=apb_rsp_item::type_id::create("t",this); t.write=vif.monitor_cb.pwrite; t.addr=vif.monitor_cb.paddr;
      t.data=vif.monitor_cb.pwdata; t.rdata=vif.monitor_cb.prdata; t.error=vif.monitor_cb.pslverr; ap.write(t);
    end
  end endtask
endclass

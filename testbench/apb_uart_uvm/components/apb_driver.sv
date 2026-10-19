class apb_driver extends uvm_driver #(apb_seq_item);
  `uvm_component_utils(apb_driver)
  virtual apb_uart_if vif;

  function new(string name="apb_driver", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_uart_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","apb_driver: virtual interface not set")
  endfunction

  task run_phase(uvm_phase phase);
    apb_seq_item req;
    forever begin
      seq_item_port.get_next_item(req);
      drive_transfer(req);
      seq_item_port.item_done();
    end
  endtask

  task automatic drive_transfer(apb_seq_item tr);
    @(negedge vif.PCLK);
    vif.psel=1; vif.penable=0;
    vif.paddr=tr.paddr; vif.pwrite=tr.pwrite; vif.pwdata=tr.pwdata;
    @(negedge vif.PCLK);
    vif.penable=1;
    do @(posedge vif.PCLK); 
    while (!vif.pready);
    tr.prdata=vif.prdata;
    tr.pslverr=vif.pslverr;
    @(negedge vif.PCLK);
    vif.psel=0; vif.penable=0; vif.pwrite=0;
    vif.paddr='0; vif.pwdata='0;
  endtask
endclass
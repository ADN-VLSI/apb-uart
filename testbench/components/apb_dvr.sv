`ifndef APB_DVR_SV
`define APB_DVR_SV

class apb_dvr extends uvm_driver #(apb_seq_item, apb_rsp_item);
  `uvm_component_utils(apb_dvr)

  virtual apb_if vif;

  function new(string name = "apb_dvr", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"})
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    vif.apply_reset(1'b1);

    forever begin
      seq_item_port.get_next_item(req);
      drive_transfer(req);
      seq_item_port.item_done();
    end
  endtask

  virtual task drive_transfer(apb_seq_item item);
    apb_rsp_item        rsp;
    bit          [31:0] rdata;
    bit                 slverr;

    if (item.delay > 0) begin
      repeat (item.delay) @(posedge vif.pclk);
    end

    // Uses interface do_transaction task to handle Setup and Access phases
    vif.do_transaction(item.addr, item.write, item.wdata, rdata, slverr);

    `uvm_create_on(rsp, p_sequencer)
    rsp.set_id_info(item);
    rsp.addr   = item.addr;
    rsp.write  = item.write;
    rsp.rdata  = rdata;
    rsp.slverr = slverr;

    seq_item_port.put_response(rsp);
  endtask
endclass : apb_dvr

`endif  // APB_DVR_SV

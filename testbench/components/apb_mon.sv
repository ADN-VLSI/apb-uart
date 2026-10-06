`ifndef APB_MON_SV
`define APB_MON_SV

class apb_mon extends uvm_monitor;
  `uvm_component_utils(apb_mon)

  virtual apb_if vif;
  uvm_analysis_port #(apb_seq_item) item_collected_port;

  function new(string name = "apb_mon", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"})
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    apb_seq_item        trans;
    bit          [31:0] addr;
    bit                 write;
    bit          [31:0] data;
    bit                 slverr;

    forever begin
      vif.get_transaction(addr, write, data, slverr);
      trans = apb_seq_item::type_id::create("trans");
      trans.addr = addr;
      trans.write = write;
      trans.slverr = slverr;
      if (write) begin
        trans.wdata = data;
      end else begin
        trans.rdata = data;
      end
      item_collected_port.write(trans);
    end
  endtask
endclass : apb_mon

`endif  // APB_MON_SV

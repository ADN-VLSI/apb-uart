class apb_write_seq extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(apb_write_seq)
  bit [31:0] addr;
  bit [31:0] data;

  function new(string name="apb_write_seq");
    super.new(name);
  endfunction

  task body();
    apb_seq_item req;
    req=apb_seq_item::type_id::create("req");
    start_item(req);
    req.write=1'b1;
    req.addr=addr;
    req.data=data;
    finish_item(req);
    if (req.error) `uvm_error("APB_WRITE_ERROR", $sformatf("write to 0x%08h returned PSLVERR", addr))
  endtask
endclass

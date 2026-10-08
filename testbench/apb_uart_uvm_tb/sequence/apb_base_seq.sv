`ifndef __GUARD_APB_BASE_SEQ_SV__
`define __GUARD_APB_BASE_SEQ_SV__ 0

class apb_base_seq extends uvm_sequence #(apb_seq_item);

    `uvm_object_utils(apb_base_seq)

    function new(string name = "apb_base_seq");
        super.new(name);
    endfunction

    // ------------------------------------------------------------
    // APB Write Helper
    // ------------------------------------------------------------
    virtual task apb_write(
        input bit [31:0] addr,
        input bit [31:0] data
    );

        apb_seq_item req;

        req = apb_seq_item::type_id::create("req");

        start_item(req);

        req.paddr  = addr;
        req.pwrite = 1'b1;
        req.pwdata = data;

        finish_item(req);

    endtask


    // ------------------------------------------------------------
    // APB Read Helper
    // ------------------------------------------------------------
    virtual task apb_read(
        input bit [31:0] addr
    );

        apb_seq_item req;

        req = apb_seq_item::type_id::create("req");

        start_item(req);

        req.paddr  = addr;
        req.pwrite = 1'b0;
        req.pwdata = '0;

        finish_item(req);

    endtask


    // ------------------------------------------------------------
    // APB Write using 32-bit register value
    // ------------------------------------------------------------
    virtual task write_reg(
        input bit [31:0] addr,
        input bit [31:0] data
    );

        apb_write(addr, data);

    endtask


    // ------------------------------------------------------------
    // APB Read using register address
    // ------------------------------------------------------------
    virtual task read_reg(
        input bit [31:0] addr
    );

        apb_read(addr);

    endtask

endclass

`endif
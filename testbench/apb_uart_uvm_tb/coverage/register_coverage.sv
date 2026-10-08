`ifndef REGISTER_COVERAGE_SV
`define REGISTER_COVERAGE_SV

class register_coverage extends uvm_subscriber #(apb_seq_item);

    `uvm_component_utils(register_coverage)

    import uart_reg_if_pkg::*;

    bit [31:0] addr;
    bit        write;


    covergroup register_cg;

        option.per_instance = 1;

        cp_register: coverpoint addr {

            bins ctrl   = {ADDR_CTRL};
            bins cfg    = {ADDR_CFG};
            bins status = {ADDR_STATUS};

            bins txr    = {ADDR_TXR};
            bins txgp   = {ADDR_TXGP};
            bins txg    = {ADDR_TXG};
            bins txd    = {ADDR_TXD};

            bins rxr    = {ADDR_RXR};
            bins rxgp   = {ADDR_RXGP};
            bins rxg    = {ADDR_RXG};
            bins rxd    = {ADDR_RXD};

            bins intr   = {ADDR_INTR};
        }


        cp_access: coverpoint write {
            bins read  = {0};
            bins write = {1};
        }


        register_x_access:
            cross cp_register, cp_access;

    endgroup


    function new(
        string name = "register_coverage",
        uvm_component parent = null
    );

        super.new(name, parent);

        register_cg = new();

    endfunction


    virtual function void write(apb_seq_item t);

        addr  = t.paddr;
        write = t.pwrite;

        register_cg.sample();

    endfunction

endclass

`endif
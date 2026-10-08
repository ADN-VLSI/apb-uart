`ifndef APB_COVERAGE_SV
`define APB_COVERAGE_SV

class apb_coverage extends uvm_subscriber #(apb_seq_item);

    `uvm_component_utils(apb_coverage)

    // ------------------------------------------------------------
    // Coverage variables
    // ------------------------------------------------------------

    bit [31:0] addr;
    bit        write;
    bit [31:0] wdata;
    bit [31:0] rdata;
    bit        slverr;


    // ------------------------------------------------------------
    // APB transaction coverage
    // ------------------------------------------------------------

    covergroup apb_cg;

        option.per_instance = 1;

        cp_write: coverpoint write {
            bins read  = {0};
            bins write = {1};
        }

        cp_addr: coverpoint addr {

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

        cp_error: coverpoint slverr {
            bins no_error = {0};
            bins error    = {1};
        }

        write_x_addr: cross cp_write, cp_addr;

    endgroup


    function new(
        string name = "apb_coverage",
        uvm_component parent = null
    );

        super.new(name, parent);

        apb_cg = new();

    endfunction


    virtual function void write(apb_seq_item t);

        addr   = t.paddr;
        write  = t.pwrite;
        wdata  = t.pwdata;
        rdata  = t.prdata;
        slverr = t.pslverr;

        apb_cg.sample();

    endfunction

endclass

`endif
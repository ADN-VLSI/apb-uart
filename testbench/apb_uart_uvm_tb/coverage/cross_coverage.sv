`ifndef CROSS_COVERAGE_SV
`define CROSS_COVERAGE_SV

class cross_coverage extends uvm_component;

    `uvm_component_utils(cross_coverage)


    // ------------------------------------------------------------
    // Analysis implementations
    // ------------------------------------------------------------

    uvm_analysis_imp #(apb_seq_item,
                       cross_coverage) apb_imp;

    uvm_analysis_imp #(uart_rsp_item,
                       cross_coverage) uart_imp;


    // ------------------------------------------------------------
    // Stored transaction information
    // ------------------------------------------------------------

    bit [31:0] last_apb_addr;
    bit        last_apb_write;

    bit [7:0]  last_uart_data;
    bit        uart_valid;


    // ------------------------------------------------------------
    // Coverage
    // ------------------------------------------------------------

    covergroup cross_cg;

        option.per_instance = 1;

        cp_apb_addr: coverpoint last_apb_addr {

            bins ctrl = {ADDR_CTRL};
            bins cfg  = {ADDR_CFG};
            bins txd  = {ADDR_TXD};
            bins rxd  = {ADDR_RXD};
            bins intr = {ADDR_INTR};

        }

        cp_apb_write: coverpoint last_apb_write {
            bins read  = {0};
            bins write = {1};
        }

        cp_uart_valid: coverpoint uart_valid {
            bins invalid = {0};
            bins valid   = {1};
        }

        apb_uart_cross:
            cross cp_apb_addr,
                  cp_apb_write,
                  cp_uart_valid;

    endgroup


    function new(
        string name = "cross_coverage",
        uvm_component parent = null
    );

        super.new(name, parent);

        apb_imp  = new("apb_imp", this);
        uart_imp = new("uart_imp", this);

        cross_cg = new();

    endfunction


    virtual function void write(apb_seq_item t);

        last_apb_addr  = t.paddr;
        last_apb_write = t.pwrite;

    endfunction


    virtual function void write(uart_rsp_item t);

        last_uart_data  = t.data;
        uart_valid      = t.valid;

        cross_cg.sample();

    endfunction

endclass

`endif
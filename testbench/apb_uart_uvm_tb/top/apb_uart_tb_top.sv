module apb_uart_tb_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"


    // ------------------------------------------------------------
    // Clock/reset
    // ------------------------------------------------------------

    logic PCLK;
    logic PRESETn;


    initial begin
        PCLK = 1'b0;
        forever #5ns PCLK = ~PCLK;
    end


    initial begin

        PRESETn = 1'b0;

        repeat (5)
            @(posedge PCLK);

        PRESETn = 1'b1;

    end


    // ------------------------------------------------------------
    // Interfaces
    // ------------------------------------------------------------

    apb_if apb_vif (
        .PCLK   (PCLK),
        .PRESETn(PRESETn)
    );


    uart_if uart_vif (
        .PCLK   (PCLK),
        .PRESETn(PRESETn)
    );


    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    apb_req_t  apb_req;
    apb_resp_t apb_resp;


    apb_uart_top dut (

        .PCLK     (PCLK),
        .PRESETn  (PRESETn),

        .apb_req_i(apb_req),
        .apb_resp_o(apb_resp),

        .UART_TX  (uart_vif.uart_tx),
        .UART_RX  (uart_vif.uart_rx),

        .UART_IRQ ()
    );


    // ------------------------------------------------------------
    // APB interface → DUT
    // ------------------------------------------------------------

    assign apb_req.psel    = apb_vif.psel;
    assign apb_req.penable = apb_vif.penable;
    assign apb_req.pwrite  = apb_vif.pwrite;
    assign apb_req.paddr   = apb_vif.paddr;
    assign apb_req.pwdata  = apb_vif.pwdata;


    assign apb_vif.prdata  = apb_resp.prdata;
    assign apb_vif.pready  = apb_resp.pready;
    assign apb_vif.pslverr = apb_resp.pslverr;


    // ------------------------------------------------------------
    // UVM configuration
    // ------------------------------------------------------------

    initial begin

        uvm_config_db#(virtual apb_if)::set(
            null,
            "uvm_test_top.env.apb_agent_h.*",
            "vif",
            apb_vif
        );


        uvm_config_db#(virtual uart_if)::set(
            null,
            "uvm_test_top.env.uart_agent_h.*",
            "vif",
            uart_vif
        );


        run_test();

    end

endmodule
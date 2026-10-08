`ifndef __GUARD_UART_EN_APB_SEQ_SV__
`define __GUARD_UART_EN_APB_SEQ_SV__ 0

class uart_en_apb_seq extends apb_base_seq;

    `uvm_object_utils(uart_en_apb_seq)

    import uart_reg_if_pkg::*;

    function new(string name = "uart_en_apb_seq");
        super.new(name);
    endfunction


    virtual task body();

        uart_ctrl_t ctrl;
        uart_cfg_t  cfg;

        `uvm_info(
            get_type_name(),
            "Configuring and enabling UART",
            UVM_MEDIUM
        )

        // --------------------------------------------------------
        // Start from reset configuration
        // --------------------------------------------------------

        ctrl = CTRL_RST;
        cfg  = CFG_RST;


        // --------------------------------------------------------
        // Configure UART
        //
        // Default CFG_RST:
        //   data_bits = 2'b11
        //   prescaler = 4'h4
        //   clk_div   = 12'h05B
        //   parity    = disabled
        //   stop_bits = 0
        // --------------------------------------------------------

        apb_write(
            ADDR_CFG,
            cfg
        );


        // --------------------------------------------------------
        // Enable TX and RX
        // --------------------------------------------------------

        ctrl.tx_en = 1'b1;
        ctrl.rx_en = 1'b1;

        apb_write(
            ADDR_CTRL,
            ctrl
        );


        // --------------------------------------------------------
        // Verify status
        // --------------------------------------------------------

        apb_read(ADDR_STATUS);


        `uvm_info(
            get_type_name(),
            "UART TX/RX enabled",
            UVM_MEDIUM
        )

    endtask

endclass

`endif
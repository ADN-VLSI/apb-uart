`ifndef __GUARD_ALL_REG_ACCESS_SEQ_SV__
`define __GUARD_ALL_REG_ACCESS_SEQ_SV__ 0

class all_reg_access_seq extends apb_base_seq;

    `uvm_object_utils(all_reg_access_seq)

    import uart_reg_if_pkg::*;

    function new(string name = "all_reg_access_seq");
        super.new(name);
    endfunction


    virtual task body();

        uart_ctrl_t   ctrl;
        uart_cfg_t    cfg;
        uart_status_t status;
        uart_intr_t   intr;

        `uvm_info(
            get_type_name(),
            "Starting all register access sequence",
            UVM_MEDIUM
        )

        ///////////////////////////////////////////////////////////
        // CTRL register
        ///////////////////////////////////////////////////////////

        ctrl = CTRL_RST;

        ctrl.tx_en = 1'b1;
        ctrl.rx_en = 1'b1;

        apb_write(
            ADDR_CTRL,
            ctrl
        );

        apb_read(ADDR_CTRL);


        ///////////////////////////////////////////////////////////
        // CFG register
        ///////////////////////////////////////////////////////////

        cfg = CFG_RST;

        apb_write(
            ADDR_CFG,
            cfg
        );

        apb_read(ADDR_CFG);


        ///////////////////////////////////////////////////////////
        // STATUS register - Read Only
        ///////////////////////////////////////////////////////////

        apb_read(ADDR_STATUS);


        ///////////////////////////////////////////////////////////
        // TX Request register
        ///////////////////////////////////////////////////////////

        apb_write(
            ADDR_TXR,
            32'h0000_0001
        );

        apb_read(ADDR_TXR);


        ///////////////////////////////////////////////////////////
        // TX Grant Pending
        ///////////////////////////////////////////////////////////

        apb_read(ADDR_TXGP);


        ///////////////////////////////////////////////////////////
        // TX Grant
        ///////////////////////////////////////////////////////////

        apb_read(ADDR_TXG);


        ///////////////////////////////////////////////////////////
        // TX Data
        ///////////////////////////////////////////////////////////

        apb_write(
            ADDR_TXD,
            32'h0000_0055
        );


        ///////////////////////////////////////////////////////////
        // RX Request
        ///////////////////////////////////////////////////////////

        apb_write(
            ADDR_RXR,
            32'h0000_0001
        );

        apb_read(ADDR_RXR);


        ///////////////////////////////////////////////////////////
        // RX Grant Pending
        ///////////////////////////////////////////////////////////

        apb_read(ADDR_RXGP);


        ///////////////////////////////////////////////////////////
        // RX Grant
        ///////////////////////////////////////////////////////////

        apb_read(ADDR_RXG);


        ///////////////////////////////////////////////////////////
        // RX Data
        ///////////////////////////////////////////////////////////

        apb_read(ADDR_RXD);


        ///////////////////////////////////////////////////////////
        // Interrupt register
        ///////////////////////////////////////////////////////////

        intr = INTR_RST;

        intr.tx_empty = 1'b1;
        intr.rx_empty = 1'b1;

        apb_write(
            ADDR_INTR,
            intr
        );

        apb_read(ADDR_INTR);


        `uvm_info(
            get_type_name(),
            "Completed all register access sequence",
            UVM_MEDIUM
        )

    endtask

endclass

`endif
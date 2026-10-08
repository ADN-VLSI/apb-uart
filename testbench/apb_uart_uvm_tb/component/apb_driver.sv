`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

class apb_driver extends uvm_driver #(apb_seq_item);

    `uvm_component_utils(apb_driver)

    virtual apb_if vif;

    function new(
        string name = "apb_driver",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual apb_if)::get(
                this,
                "",
                "vif",
                vif
            )) begin

            `uvm_fatal(
                "APB_DRV_NO_VIF",
                "Virtual APB interface was not found"
            )

        end

    endfunction


    task run_phase(uvm_phase phase);

        // --------------------------------------------------------
        // Initialize APB signals
        // --------------------------------------------------------

        vif.psel    = 1'b0;
        vif.penable = 1'b0;
        vif.pwrite  = 1'b0;
        vif.paddr   = '0;
        vif.pwdata  = '0;


        forever begin

            seq_item_port.get_next_item(req);

            drive_transfer(req);

            seq_item_port.item_done();

        end

    endtask


    task drive_transfer(apb_seq_item tr);

        // --------------------------------------------------------
        // APB SETUP phase
        // --------------------------------------------------------

        @(vif.cb_drv);

        vif.cb_drv.psel    <= 1'b1;
        vif.cb_drv.penable <= 1'b0;
        vif.cb_drv.pwrite  <= tr.pwrite;
        vif.cb_drv.paddr   <= tr.paddr;
        vif.cb_drv.pwdata  <= tr.pwdata;


        // --------------------------------------------------------
        // APB ACCESS phase
        // --------------------------------------------------------

        @(vif.cb_drv);

        vif.cb_drv.penable <= 1'b1;


        // --------------------------------------------------------
        // Wait for PREADY
        // --------------------------------------------------------

        while (!vif.cb_drv.pready) begin
            @(vif.cb_drv);
        end


        // --------------------------------------------------------
        // Capture response
        // --------------------------------------------------------

        tr.prdata  = vif.cb_drv.prdata;
        tr.pready  = vif.cb_drv.pready;
        tr.pslverr = vif.cb_drv.pslverr;


        // --------------------------------------------------------
        // Return APB to idle
        // --------------------------------------------------------

        @(vif.cb_drv);

        vif.cb_drv.psel    <= 1'b0;
        vif.cb_drv.penable <= 1'b0;
        vif.cb_drv.pwrite  <= 1'b0;
        vif.cb_drv.paddr   <= '0;
        vif.cb_drv.pwdata  <= '0;

    endtask

endclass

`endif
`ifndef __GUARD_APB_MONITOR_SV__
`define __GUARD_APB_MONITOR_SV__ 0

class apb_monitor extends uvm_monitor;

    `uvm_component_utils(apb_monitor)

    virtual apb_if vif;

    uvm_analysis_port #(apb_seq_item) apb_analysis_port;


    function new(
        string name = "apb_monitor",
        uvm_component parent = null
    );
        super.new(name, parent);

        apb_analysis_port =
            new("apb_analysis_port", this);
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
                get_type_name(),
                "APB virtual interface not found"
            )

        end

    endfunction


    task run_phase(uvm_phase phase);

        forever begin

            @(posedge vif.PCLK);

            // APB ACCESS phase
            if (vif.psel &&
                vif.penable &&
                vif.pready) begin

                collect_transaction();

            end

        end

    endtask


    virtual task collect_transaction();

        apb_seq_item item;

        item = apb_seq_item::type_id::create(
            "item",
            this
        );

        item.paddr   = vif.paddr;
        item.pwrite  = vif.pwrite;
        item.pwdata  = vif.pwdata;
        item.prdata  = vif.prdata;
        item.pslverr = vif.pslverr;


        `uvm_info(
            get_type_name(),
            item.convert2string(),
            UVM_HIGH
        )


        apb_analysis_port.write(item);

    endtask

endclass

`endif
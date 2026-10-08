`ifndef PROTOCOL_COVERAGE_SV
`define PROTOCOL_COVERAGE_SV

class protocol_coverage extends uvm_subscriber #(apb_seq_item);

    `uvm_component_utils(protocol_coverage)

    bit        write;
    bit        error;


    covergroup protocol_cg;

        option.per_instance = 1;

        cp_direction: coverpoint write {
            bins read  = {0};
            bins write = {1};
        }

        cp_error: coverpoint error {
            bins success = {0};
            bins error   = {1};
        }

        direction_x_error:
            cross cp_direction, cp_error;

    endgroup


    function new(
        string name = "protocol_coverage",
        uvm_component parent = null
    );

        super.new(name, parent);

        protocol_cg = new();

    endfunction


    virtual function void write(apb_seq_item t);

        write = t.pwrite;
        error = t.pslverr;

        protocol_cg.sample();

    endfunction

endclass

`endif
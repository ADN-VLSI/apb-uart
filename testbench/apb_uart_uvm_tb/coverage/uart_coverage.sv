`ifndef UART_COVERAGE_SV
`define UART_COVERAGE_SV

class uart_coverage extends uvm_subscriber #(uart_rsp_item);

    `uvm_component_utils(uart_coverage)

    bit [7:0] data;
    bit       valid;
    bit       parity_error;
    bit       frame_error;


    covergroup uart_cg;

        option.per_instance = 1;

        cp_data: coverpoint data {
            bins zero      = {8'h00};
            bins all_ones  = {8'hFF};
            bins low       = {[8'h01:8'h3F]};
            bins mid       = {[8'h40:8'hBF]};
            bins high      = {[8'hC0:8'hFE]};
        }

        cp_valid: coverpoint valid {
            bins invalid = {0};
            bins valid   = {1};
        }

        cp_parity_error: coverpoint parity_error {
            bins no_error = {0};
            bins error    = {1};
        }

        cp_frame_error: coverpoint frame_error {
            bins no_error = {0};
            bins error    = {1};
        }

        data_x_error: cross cp_data, cp_parity_error;

    endgroup


    function new(
        string name = "uart_coverage",
        uvm_component parent = null
    );

        super.new(name, parent);

        uart_cg = new();

    endfunction


    virtual function void write(uart_rsp_item t);

        data         = t.data;
        valid        = t.valid;
        parity_error = t.parity_error;
        frame_error  = t.frame_error;

        uart_cg.sample();

    endfunction

endclass

`endif
`ifndef __GUARD_RANDOM_APB_WDATA_SEQ_SV__
`define __GUARD_RANDOM_APB_WDATA_SEQ_SV__ 0

class random_apb_wdata_seq extends apb_base_seq;

    `uvm_object_utils(random_apb_wdata_seq)

    import uart_reg_if_pkg::*;

    rand int unsigned num_transactions;

    rand bit [31:0] random_wdata;

    constraint num_transactions_c {
        num_transactions inside {[10:100]};
    }

    function new(string name = "random_apb_wdata_seq");
        super.new(name);
    endfunction


    virtual task body();

        bit [31:0] addr;
        bit [31:0] data;

        if (!randomize()) begin
            `uvm_fatal(
                get_type_name(),
                "Failed to randomize random_apb_wdata_seq"
            )
        end

        repeat (num_transactions) begin

            // Select only writable registers
            case ($urandom_range(0, 4))

                0: begin
                    addr = ADDR_CTRL;
                    data = random_wdata;
                end

                1: begin
                    addr = ADDR_CFG;
                    data = random_wdata;
                end

                2: begin
                    addr = ADDR_TXR;
                    data = random_wdata;
                end

                3: begin
                    addr = ADDR_TXD;
                    data = random_wdata;
                end

                4: begin
                    addr = ADDR_RXR;
                    data = random_wdata;
                end

                default: begin
                    addr = ADDR_INTR;
                    data = random_wdata;
                end

            endcase

            `uvm_info(
                get_type_name(),
                $sformatf(
                    "Random APB write: addr=0x%08h data=0x%08h",
                    addr,
                    data
                ),
                UVM_LOW
            )

            apb_write(addr, data);

        end

    endtask

endclass

`endif
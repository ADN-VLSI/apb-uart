`ifndef __GUARD_RANDOM_APB_RDATA_SEQ_SV__
`define __GUARD_RANDOM_APB_RDATA_SEQ_SV__ 0

class random_apb_rdata_seq extends apb_base_seq;

    `uvm_object_utils(random_apb_rdata_seq)

    import uart_reg_if_pkg::*;

    rand int unsigned num_transactions;

    constraint num_transactions_c {
        num_transactions inside {[10:100]};
    }

    function new(string name = "random_apb_rdata_seq");
        super.new(name);
    endfunction


    virtual task body();

        bit [31:0] addr;

        if (!randomize()) begin
            `uvm_fatal(
                get_type_name(),
                "Failed to randomize random_apb_rdata_seq"
            )
        end

        repeat (num_transactions) begin

            // Select a readable register
            case ($urandom_range(0, 5))

                0: addr = ADDR_CTRL;
                1: addr = ADDR_CFG;
                2: addr = ADDR_STATUS;
                3: addr = ADDR_TXGP;
                4: addr = ADDR_TXG;
                5: addr = ADDR_RXGP;
                default: addr = ADDR_RXG;

            endcase

            `uvm_info(
                get_type_name(),
                $sformatf(
                    "Reading register addr=0x%08h",
                    addr
                ),
                UVM_LOW
            )

            apb_read(addr);

        end

    endtask

endclass

`endif
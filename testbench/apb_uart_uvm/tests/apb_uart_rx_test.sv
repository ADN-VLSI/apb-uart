class apb_uart_rx_test extends apb_uart_base_test;

    `uvm_component_utils(apb_uart_rx_test)

    function new(string name = "apb_uart_rx_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        localparam int unsigned FRAME_COUNT = 5;
        localparam bit [31:0] UART_CTRL_ADDR = 32'h00000000;
        localparam bit [31:0] UART_CFG_ADDR = 32'h00000004;
        localparam bit [31:0] UART_STAT_ADDR = 32'h00000008;
        localparam bit [31:0] UART_RX_COUNT_MASK = 32'h000FFC00;
        apb_access_seq apb_seq;
        uart_rx_seq seq;
        int unsigned initial_pass_count;

        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "TEST START: UART RX test; inject and verify 5 randomized bytes using 8-N-1 framing",
                  UVM_LOW)

        wait (env.apb.driver.vif.PRESETn === 1'b1);

        apb_seq = apb_access_seq::type_id::create("reset_seq");
        apb_seq.is_write = 1'b1;
        apb_seq.addr = UART_CTRL_ADDR;
        apb_seq.data = 32'h00000001;
        apb_seq.start(env.apb.sequencer);

        apb_seq = apb_access_seq::type_id::create("cfg_seq");
        apb_seq.is_write = 1'b1;
        apb_seq.addr = UART_CFG_ADDR;
        apb_seq.data = 32'h00030002;
        apb_seq.start(env.apb.sequencer);

        apb_seq = apb_access_seq::type_id::create("enable_seq");
        apb_seq.is_write = 1'b1;
        apb_seq.addr = UART_CTRL_ADDR;
        apb_seq.data = 32'h00000010;
        apb_seq.start(env.apb.sequencer);

        initial_pass_count = env.sb.pass_count;

        for (int unsigned frame = 0; frame < FRAME_COUNT; frame++) begin
            seq = uart_rx_seq::type_id::create($sformatf("rx_seq_%0d", frame));
            seq.frame_count = 1;
            seq.start(env.uart.sequencer);

            apb_seq = apb_access_seq::type_id::create($sformatf("status_seq_%0d", frame));
            apb_seq.is_write = 1'b0;
            apb_seq.addr = UART_STAT_ADDR;
            apb_seq.start(env.apb.sequencer);

            if (((apb_seq.read_data & UART_RX_COUNT_MASK) >> 10) == frame + 1) begin
                env.sb.pass_count++;
                `uvm_info("UART_RX_SB",
                          $sformatf("RX COUNT PASS: expected %0d frames, observed %0d",
                                    frame + 1,
                                    (apb_seq.read_data & UART_RX_COUNT_MASK) >> 10),
                          UVM_LOW)
            end else begin
                env.sb.fail_count++;
                `uvm_error("UART_RX_SB",
                           $sformatf("RX COUNT FAIL: expected %0d frames, observed %0d",
                                     frame + 1,
                                     (apb_seq.read_data & UART_RX_COUNT_MASK) >> 10))
            end
        end

        `uvm_info(get_type_name(),
                  $sformatf("TEST COMPLETE: UART RX verified pass count: %0d/%0d",
                            env.sb.pass_count - initial_pass_count,
                            FRAME_COUNT),
                  UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass

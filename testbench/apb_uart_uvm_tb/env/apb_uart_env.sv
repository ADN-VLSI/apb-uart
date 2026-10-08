`ifndef APB_UART_ENV_SV
`define APB_UART_ENV_SV

class apb_uart_env extends uvm_env;

    `uvm_component_utils(apb_uart_env)


    // ------------------------------------------------------------
    // Agents
    // ------------------------------------------------------------

    apb_agent  apb_agent_h;
    uart_agent uart_agent_h;


    // ------------------------------------------------------------
    // Scoreboard
    // ------------------------------------------------------------

    apb_uart_scbd scoreboard;


    // ------------------------------------------------------------
    // Coverage
    // ------------------------------------------------------------

    apb_coverage       apb_cov;
    uart_coverage      uart_cov;
    register_coverage  reg_cov;
    protocol_coverage  protocol_cov;
    cross_coverage     cross_cov;


    // ------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------

    function new(
        string name = "apb_uart_env",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    // ------------------------------------------------------------
    // Build phase
    // ------------------------------------------------------------

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);


        // --------------------------------------------------------
        // Agents
        // --------------------------------------------------------

        apb_agent_h =
            apb_agent::type_id::create(
                "apb_agent_h",
                this
            );

        uart_agent_h =
            uart_agent::type_id::create(
                "uart_agent_h",
                this
            );


        // --------------------------------------------------------
        // Active agents
        // --------------------------------------------------------

        apb_agent_h.is_active  = UVM_ACTIVE;
        uart_agent_h.is_active = UVM_ACTIVE;


        // --------------------------------------------------------
        // Scoreboard
        // --------------------------------------------------------

        scoreboard =
            apb_uart_scbd::type_id::create(
                "scoreboard",
                this
            );


        // --------------------------------------------------------
        // Coverage
        // --------------------------------------------------------

        apb_cov =
            apb_coverage::type_id::create(
                "apb_cov",
                this
            );

        uart_cov =
            uart_coverage::type_id::create(
                "uart_cov",
                this
            );

        reg_cov =
            register_coverage::type_id::create(
                "reg_cov",
                this
            );

        protocol_cov =
            protocol_coverage::type_id::create(
                "protocol_cov",
                this
            );

        cross_cov =
            cross_coverage::type_id::create(
                "cross_cov",
                this
            );

    endfunction


    // ------------------------------------------------------------
    // Connect phase
    // ------------------------------------------------------------

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);


        // --------------------------------------------------------
        // APB monitor
        // --------------------------------------------------------

        apb_agent_h.monitor.apb_analysis_port.connect(
            scoreboard.apb_fifo.analysis_export
        );

        apb_agent_h.monitor.apb_analysis_port.connect(
            apb_cov.analysis_export
        );

        apb_agent_h.monitor.apb_analysis_port.connect(
            reg_cov.analysis_export
        );

        apb_agent_h.monitor.apb_analysis_port.connect(
            protocol_cov.analysis_export
        );

        apb_agent_h.monitor.apb_analysis_port.connect(
            cross_cov.apb_imp
        );


        // --------------------------------------------------------
        // UART monitor
        // --------------------------------------------------------

        uart_agent_h.monitor.uart_analysis_port.connect(
            scoreboard.uart_fifo.analysis_export
        );

        uart_agent_h.monitor.uart_analysis_port.connect(
            uart_cov.analysis_export
        );

        uart_agent_h.monitor.uart_analysis_port.connect(
            cross_cov.uart_imp
        );

    endfunction

endclass

`endif

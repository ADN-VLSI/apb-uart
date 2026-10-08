`ifndef ALL_REG_ACCESS_TEST_SV
`define ALL_REG_ACCESS_TEST_SV

class all_reg_access_test extends base_test;

    `uvm_component_utils(all_reg_access_test)

    function new(
        string name = "all_reg_access_test",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    task run_phase(uvm_phase phase);

        all_reg_access_seq seq;

        phase.raise_objection(this);


        `uvm_info(
            get_type_name(),
            "Starting all register access test",
            UVM_MEDIUM
        )


        seq = all_reg_access_seq::type_id::create(
            "seq"
        );


        seq.start(
            env.apb_agent_h.sequencer
        );


        phase.drop_objection(this);

    endtask

endclass

`endif
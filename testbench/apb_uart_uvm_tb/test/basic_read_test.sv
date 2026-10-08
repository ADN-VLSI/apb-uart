`ifndef BASIC_READ_TEST_SV
`define BASIC_READ_TEST_SV

class basic_read_test extends base_test;

    `uvm_component_utils(basic_read_test)

    function new(
        string name = "basic_read_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);

        all_reg_access_seq seq;

        phase.raise_objection(this);

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
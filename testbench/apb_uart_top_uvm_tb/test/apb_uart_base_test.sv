class apb_uart_base_test extends uvm_test;
  `uvm_component_utils(apb_uart_base_test)
  apb_uart_env env;
  function new(string name,uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase); super.build_phase(phase); env=apb_uart_env::type_id::create("env",this); endfunction
  task apb_write(bit [31:0] addr, bit [31:0] data);
    apb_write_seq seq=apb_write_seq::type_id::create("apb_write_seq");
    seq.addr=addr;
    seq.data=data;
    seq.start(env.apb.sequencer);
  endtask
  task run_phase(uvm_phase phase); phase.raise_objection(this); #200ns; apb_write(0,'h8); phase.drop_objection(this); endtask
endclass

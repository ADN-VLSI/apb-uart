class apb_write_seq extends apb_base_seq;

  `uvm_object_utils(apb_write_seq)

  rand bit [31:0] addr;
  rand bit [31:0] data;

  constraint c_addr {
    addr[1:0] == 2'b00;
  }

  function new(string name = "apb_write_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info("APB_WRITE_SEQ",
              $sformatf("Writing 0x%08h to address 0x%08h",
                        data, addr),
              UVM_MEDIUM)

    apb_write(addr, data);

  endtask

endclass
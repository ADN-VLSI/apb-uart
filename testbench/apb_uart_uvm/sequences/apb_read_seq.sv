class apb_read_seq extends apb_base_seq;

  `uvm_object_utils(apb_read_seq)

  rand bit [31:0] addr;

  bit [31:0] read_data;

  constraint c_addr {
    addr[1:0] == 2'b00;
  }

  function new(string name = "apb_read_seq");
    super.new(name);
  endfunction

  task body();

    apb_read(addr, read_data);

    `uvm_info("APB_READ_SEQ",
              $sformatf("Address: 0x%08h, Read Data: 0x%08h",
                        addr, read_data),
              UVM_MEDIUM)

  endtask

endclass
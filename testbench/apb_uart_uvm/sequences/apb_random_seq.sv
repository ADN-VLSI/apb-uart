class apb_random_seq extends apb_base_seq;

  `uvm_object_utils(apb_random_seq)

  function new(string name = "apb_random_seq");
    super.new(name);
  endfunction

  task body();

    apb_seq_item req;

    repeat (20) begin

      req = apb_seq_item::type_id::create("req");

      start_item(req);

      if (!req.randomize() with {
        paddr inside {
          32'h0000_0000,
          32'h0000_0004,
          32'h0000_0008,
          32'h0000_001C,
          32'h0000_002C,
          32'h0000_0030
        };
      }) begin

        `uvm_fatal("RAND_FAIL",
                   "APB transaction randomization failed")

      end

      finish_item(req);

      if (req.pslverr) begin

        `uvm_warning("APB_RANDOM",
                     $sformatf(
                       "APB error at address 0x%08h",
                       req.paddr
                     ))

      end

    end

  endtask

endclass
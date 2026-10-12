`ifndef __GUARD_RANDOM_APB_WDATA_SEQ_SV__
`define __GUARD_RANDOM_APB_WDATA_SEQ_SV__ 0

`include "apb_base_seq.sv"

class random_apb_wdata_seq extends apb_base_seq;

  `uvm_object_utils(random_apb_wdata_seq)

  rand int unsigned num_transactions;

  constraint num_transactions_c {
    num_transactions inside {[10:50]};
  }

  function new(string name = "random_apb_wdata_seq");
    super.new(name);
  endfunction

  virtual task body();

    apb_seq_item req;

    if (!randomize()) begin
      `uvm_fatal(get_type_name(), "Failed to randomize sequence configuration")
    end

    `uvm_info(
      get_type_name(),
      $sformatf("Starting %0d randomized APB writes", num_transactions),
      UVM_LOW
    )

    repeat (num_transactions) begin

      req = apb_seq_item::type_id::create("req");

      start_item(req);

      if (!req.randomize() with {
        we == 1'b1;
      }) begin
        `uvm_fatal(get_type_name(), "Failed to randomize APB write request")
      end

      `uvm_info(
        get_type_name(),
        $sformatf("Random APB WRITE: %s", req.to_string()),
        UVM_MEDIUM
      )

      finish_item(req);

    end

    `uvm_info(get_type_name(), "Randomized APB writes completed", UVM_LOW)

  endtask : body

endclass

`endif
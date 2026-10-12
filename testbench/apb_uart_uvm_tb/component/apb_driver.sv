`ifndef __GUARD_APB_DRIVER_SV__
`define __GUARD_APB_DRIVER_SV__ 0

class apb_driver extends uvm_driver #(
  apb_seq_item,
  apb_rsp_item
);

  // ------------------------------------------------------------
  // UVM Component Registration
  // ------------------------------------------------------------

  `uvm_component_utils(apb_driver)

  // ------------------------------------------------------------
  // Virtual Interface
  // ------------------------------------------------------------

  virtual apb_if vif;

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(
    string name = "apb_driver",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction : new

  // ------------------------------------------------------------
  // Build Phase
  // ------------------------------------------------------------

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual apb_if)::get(
          this, "", "vif", vif
        )) begin

      `uvm_fatal(
        get_type_name(),
        "APB virtual interface was not configured"
      )

    end

  endfunction : build_phase

  // ------------------------------------------------------------
  // Run Phase
  // ------------------------------------------------------------

  virtual task run_phase(uvm_phase phase);

    apb_seq_item req;
    apb_rsp_item rsp;

    // Initialize APB signals.
    drive_idle();

    // Wait for reset release.
    wait (vif.PRESETn === 1'b1);

    forever begin

      // Retrieve the next transaction from the sequencer.
      seq_item_port.get_next_item(req);

      `uvm_info(
        get_type_name(),
        $sformatf(
          "Starting APB transaction: %s",
          req.to_string()
        ),
        UVM_MEDIUM
      )

      // Create response transaction.
      rsp = apb_rsp_item::type_id::create("rsp");

      // Execute APB transfer.
      drive_transfer(req, rsp);

      // Associate response with the original request.
      rsp.set_id_info(req);

      // Complete the transaction and return the response.
      seq_item_port.item_done(rsp);

      `uvm_info(
        get_type_name(),
        $sformatf(
          "Completed APB transaction: %s",
          rsp.to_string()
        ),
        UVM_MEDIUM
      )

    end

  endtask : run_phase

  // ------------------------------------------------------------
  // Drive APB Idle State
  // ------------------------------------------------------------

  virtual task drive_idle();

    @(negedge vif.PCLK);

    vif.psel    = 1'b0;
    vif.penable = 1'b0;
    vif.paddr   = '0;
    vif.pprot   = '0;
    vif.pwrite  = 1'b0;
    vif.pwdata  = '0;
    vif.pstrb   = '0;

  endtask : drive_idle

  // ------------------------------------------------------------
  // Drive APB Transfer
  // ------------------------------------------------------------

  virtual task drive_transfer(
    input  apb_seq_item req,
    output apb_rsp_item rsp
  );

    // ----------------------------------------------------------
    // Initialize Response
    // ----------------------------------------------------------

    rsp.we     = req.we;
    rsp.addr   = req.addr;
    rsp.data   = '0;
    rsp.slverr = 1'b0;

    // ----------------------------------------------------------
    // Setup Phase
    // ----------------------------------------------------------

    // Drive signals on the falling edge to avoid races with
    // synchronous DUT logic sampling on the rising edge.

    @(negedge vif.PCLK);

    vif.psel    = 1'b1;
    vif.penable = 1'b0;
    vif.paddr   = req.addr;
    vif.pwrite  = req.we;
    vif.pwdata  = req.we ? req.data : '0;

    // Use default protection and byte-strobe values.
    vif.pprot = '0;
    vif.pstrb = req.we ? '1 : '0;

    // ----------------------------------------------------------
    // Access Phase
    // ----------------------------------------------------------

    @(negedge vif.PCLK);

    vif.penable = 1'b1;

    // ----------------------------------------------------------
    // Wait For Transfer Completion
    // ----------------------------------------------------------

    // Wait until the slave asserts PREADY.
    // Keep APB control and address signals stable while waiting.

    do begin
      @(posedge vif.PCLK);
    end while (vif.pready !== 1'b1);

    // ----------------------------------------------------------
    // Capture Response
    // ----------------------------------------------------------

    rsp.slverr = vif.pslverr;

    if (!req.we) begin
      rsp.data = vif.prdata;
    end

    // ----------------------------------------------------------
    // Return Bus To Idle
    // ----------------------------------------------------------

    @(negedge vif.PCLK);

    vif.psel    = 1'b0;
    vif.penable = 1'b0;
    vif.pwrite  = 1'b0;
    vif.paddr   = '0;
    vif.pwdata  = '0;
    vif.pprot   = '0;
    vif.pstrb   = '0;

  endtask : drive_transfer

endclass : apb_driver

`endif
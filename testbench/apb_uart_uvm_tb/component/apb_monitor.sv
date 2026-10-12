`ifndef __GUARD_APB_MONITOR_SV__
`define __GUARD_APB_MONITOR_SV__ 0

class apb_monitor extends uvm_monitor;

  // ------------------------------------------------------------
  // UVM Component Registration
  // ------------------------------------------------------------

  `uvm_component_utils(apb_monitor)

  // ------------------------------------------------------------
  // Virtual Interface
  // ------------------------------------------------------------

  virtual apb_if vif;

  // ------------------------------------------------------------
  // Analysis Port
  // ------------------------------------------------------------

  uvm_analysis_port #(apb_rsp_item) ap;

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(string name = "apb_monitor",
               uvm_component parent = null);
    super.new(name, parent);

    ap = new("ap", this);
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

    apb_rsp_item tr;

    // Wait for reset release.
    wait (vif.PRESETn === 1'b1);

    forever begin

      @(posedge vif.PCLK);

      // Ignore bus activity during reset.
      if (vif.PRESETn !== 1'b1) begin
        continue;
      end

      // A transfer completes when PSEL, PENABLE, and PREADY
      // are all asserted.
      if (
        vif.PSEL    === 1'b1 &&
        vif.PENABLE === 1'b1 &&
        vif.PREADY  === 1'b1
      ) begin

        tr = apb_rsp_item::type_id::create("tr");

        // ------------------------------------------------------
        // Capture APB Transaction
        // ------------------------------------------------------

        tr.we     = vif.PWRITE;
        tr.addr   = vif.PADDR;
        tr.slverr = vif.PSLVERR;

        // For writes, capture the driven write data.
        // For reads, capture the returned read data.
        if (vif.PWRITE === 1'b1) begin
          tr.data = vif.PWDATA;
        end
        else begin
          tr.data = vif.PRDATA;
        end

        `uvm_info(
          get_type_name(),
          $sformatf("Observed APB transaction: %s", tr.to_string()),
          UVM_MEDIUM
        )

        // ------------------------------------------------------
        // Publish Transaction
        // ------------------------------------------------------

        ap.write(tr);

      end

    end

  endtask : run_phase

endclass : apb_monitor

`endif
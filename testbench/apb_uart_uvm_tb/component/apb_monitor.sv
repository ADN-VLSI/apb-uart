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

  function new(
    string name = "apb_monitor",
    uvm_component parent = null
  );

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

    forever begin

      // Wait for a completed APB transfer.
      @(posedge vif.PCLK);

      if ((vif.psel    === 1'b1) &&
          (vif.penable === 1'b1) &&
          (vif.pready  === 1'b1)) begin

        tr = apb_rsp_item::type_id::create("tr");

        // Capture transaction information.
        tr.we     = vif.pwrite;
        tr.addr   = vif.paddr;
        tr.slverr = vif.pslverr;

        if (vif.pwrite === 1'b1) begin

          tr.data = vif.pwdata;

        end
        else begin

          tr.data = vif.prdata;

        end

        `uvm_info(
          get_type_name(),
          $sformatf(
            "Observed APB transaction: %s",
            tr.to_string()
          ),
          UVM_MEDIUM
        )

        // Publish the observed transaction.
        ap.write(tr);

      end

    end

  endtask : run_phase

endclass : apb_monitor

`endif
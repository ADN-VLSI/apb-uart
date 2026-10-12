`ifndef __GUARD_UART_MONITOR_SV__
`define __GUARD_UART_MONITOR_SV__ 0

class uart_monitor extends uvm_monitor;

  // ------------------------------------------------------------
  // UVM Component Registration
  // ------------------------------------------------------------

  `uvm_component_utils(uart_monitor)

  // ------------------------------------------------------------
  // Virtual Interface
  // ------------------------------------------------------------

  virtual uart_if vif;

  // ------------------------------------------------------------
  // Analysis Port
  // ------------------------------------------------------------

  uvm_analysis_port #(uart_rsp_item) ap;

  // ------------------------------------------------------------
  // UART Configuration
  // ------------------------------------------------------------

  int baud_rate = 115200;
  int data_bits = 8;

  bit parity_en   = 0;
  bit parity_type = 0;
  bit extra_stop  = 0;

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(string name = "uart_monitor",
               uvm_component parent = null);
    super.new(name, parent);

    ap = new("ap", this);
  endfunction : new

  // ------------------------------------------------------------
  // Build Phase
  // ------------------------------------------------------------

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual uart_if)::get(
          this, "", "vif", vif
        )) begin
      `uvm_fatal(
        get_type_name(),
        "UART virtual interface was not configured"
      )
    end

    // Optional configuration overrides.
    void'(uvm_config_db#(int)::get(
      this, "", "baud_rate", baud_rate
    ));

    void'(uvm_config_db#(int)::get(
      this, "", "data_bits", data_bits
    ));

    void'(uvm_config_db#(bit)::get(
      this, "", "parity_en", parity_en
    ));

    void'(uvm_config_db#(bit)::get(
      this, "", "parity_type", parity_type
    ));

    void'(uvm_config_db#(bit)::get(
      this, "", "extra_stop", extra_stop
    ));

    if (baud_rate <= 0) begin
      `uvm_fatal(get_type_name(), "Invalid monitor baud rate")
    end

    if (!(data_bits inside {5, 6, 7, 8})) begin
      `uvm_fatal(get_type_name(), "Invalid monitor data width")
    end

  endfunction : build_phase

  // ------------------------------------------------------------
  // Run Phase
  // ------------------------------------------------------------

  virtual task run_phase(uvm_phase phase);

    uart_rsp_item tr;

    forever begin

      // Wait for a possible UART start bit.
      @(negedge vif.UART_TX);

      // Decode the frame.
      tr = uart_rsp_item::type_id::create("tr");

      if (sample_uart_frame(tr)) begin

        `uvm_info(
          get_type_name(),
          $sformatf("Observed UART frame: %s", tr.to_string()),
          UVM_MEDIUM
        )

        // Publish the observed frame.
        ap.write(tr);

      end

    end

  endtask : run_phase

  // ------------------------------------------------------------
  // Sample UART Frame
  // ------------------------------------------------------------

  virtual task sample_uart_frame(
    output uart_rsp_item tr
  );

    time bit_period;
    bit sampled_parity;
    bit expected_parity;
    bit [7:0] sampled_data;

    bit_period = 1s / baud_rate;

    sampled_data    = '0;
    sampled_parity  = 1'b0;
    expected_parity = 1'b0;

    // ----------------------------------------------------------
    // Verify Start Bit
    // ----------------------------------------------------------

    // Sample halfway through the start bit.
    #(bit_period / 2);

    if (vif.UART_TX !== 1'b0) begin

      `uvm_warning(
        get_type_name(),
        "False UART start-bit detection"
      )

      return;

    end

    // ----------------------------------------------------------
    // Sample Data Bits
    // ----------------------------------------------------------

    // Move to the center of the first data bit.
    #(bit_period);

    for (int i = 0; i < data_bits; i++) begin

      sampled_data[i] = vif.UART_TX;

      #(bit_period);

    end

    // ----------------------------------------------------------
    // Sample Parity
    // ----------------------------------------------------------

    if (parity_en) begin

      sampled_parity = vif.UART_TX;

      expected_parity =
        ^(sampled_data & ((9'h1 << data_bits) - 1));

      // parity_type = 0: even
      // parity_type = 1: odd
      if (parity_type) begin
        expected_parity = ~expected_parity;
      end

      if (sampled_parity !== expected_parity) begin
        `uvm_error(
          get_type_name(),
          $sformatf(
            "Parity error: data=0x%02h expected=%0b observed=%0b",
            sampled_data,
            expected_parity,
            sampled_parity
          )
        )
      end

      #(bit_period);

    end

    // ----------------------------------------------------------
    // Verify Stop Bit
    // ----------------------------------------------------------

    if (vif.UART_TX !== 1'b1) begin
      `uvm_error(
        get_type_name(),
        "UART stop bit is not high"
      )
    end

    #(bit_period);

    if (extra_stop) begin

      if (vif.UART_TX !== 1'b1) begin
        `uvm_error(
          get_type_name(),
          "UART second stop bit is not high"
        )
      end

      #(bit_period);

    end

    // ----------------------------------------------------------
    // Populate Response Item
    // ----------------------------------------------------------

    tr.data        = sampled_data;
    tr.baud_rate   = baud_rate;
    tr.data_bits   = data_bits;
    tr.parity_en   = parity_en;
    tr.parity_type = parity_type;
    tr.extra_stop  = extra_stop;
    tr.parity      = sampled_parity;

  endtask : sample_uart_frame

endclass : uart_monitor

`endif
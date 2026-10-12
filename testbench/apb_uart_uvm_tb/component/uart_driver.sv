`ifndef __GUARD_UART_DRIVER_SV__
`define __GUARD_UART_DRIVER_SV__ 0

class uart_driver extends uvm_driver #(
  uart_seq_item,
  uart_rsp_item
);

  // ------------------------------------------------------------
  // UVM Component Registration
  // ------------------------------------------------------------

  `uvm_component_utils(uart_driver)

  // ------------------------------------------------------------
  // Virtual Interface
  // ------------------------------------------------------------

  virtual uart_if vif;

  // ------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------

  function new(string name = "uart_driver",
               uvm_component parent = null);
    super.new(name, parent);
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
  endfunction : build_phase

  // ------------------------------------------------------------
  // Run Phase
  // ------------------------------------------------------------

  virtual task run_phase(uvm_phase phase);

    uart_seq_item req;
    uart_rsp_item rsp;

    // UART idle state is logic 1.
    vif.UART_RX = 1'b1;

    forever begin

      seq_item_port.get_next_item(req);

      `uvm_info(
        get_type_name(),
        $sformatf("Driving UART frame: %s", req.to_string()),
        UVM_MEDIUM
      )

      rsp = uart_rsp_item::type_id::create("rsp");

      // Drive the incoming UART frame.
      drive_uart_frame(req, rsp);

      // Associate the response with the original request.
      rsp.set_id_info(req);

      // Return the completed response to the sequence.
      seq_item_port.item_done(rsp);

      `uvm_info(
        get_type_name(),
        $sformatf("UART frame completed: %s", rsp.to_string()),
        UVM_MEDIUM
      )

    end

  endtask : run_phase

  // ------------------------------------------------------------
  // Drive UART Frame
  // ------------------------------------------------------------

  virtual task drive_uart_frame(
    input  uart_seq_item req,
    output uart_rsp_item rsp
  );

    time bit_period;
    bit parity_bit;

    // ----------------------------------------------------------
    // Validate Transaction Configuration
    // ----------------------------------------------------------

    if (req.baud_rate <= 0) begin
      `uvm_fatal(
        get_type_name(),
        $sformatf("Invalid baud rate: %0d", req.baud_rate)
      )
    end

    if (!(req.data_bits inside {5, 6, 7, 8})) begin
      `uvm_fatal(
        get_type_name(),
        $sformatf("Invalid data bits: %0d", req.data_bits)
      )
    end

    // Calculate the serial bit period.
    bit_period = 1s / req.baud_rate;

    // ----------------------------------------------------------
    // Prepare Response
    // ----------------------------------------------------------

    rsp.data        = req.data;
    rsp.baud_rate   = req.baud_rate;
    rsp.parity_en   = req.parity_en;
    rsp.parity_type = req.parity_type;
    rsp.extra_stop  = req.extra_stop;
    rsp.data_bits   = req.data_bits;
    rsp.parity      = 1'b0;

    // ----------------------------------------------------------
    // Start Bit
    // ----------------------------------------------------------

    // UART line idles high.
    vif.UART_RX = 1'b1;

    // Start bit is low.
    #(bit_period);
    vif.UART_RX = 1'b0;

    #(bit_period);

    // ----------------------------------------------------------
    // Data Bits: LSB First
    // ----------------------------------------------------------

    for (int i = 0; i < req.data_bits; i++) begin

      vif.UART_RX = req.data[i];

      #(bit_period);

    end

    // ----------------------------------------------------------
    // Parity Bit
    // ----------------------------------------------------------

    if (req.parity_en) begin

      // Even parity: parity bit equals XOR of the data bits.
      // Odd parity: invert that result.
      parity_bit = ^(req.data & ((9'h1 << req.data_bits) - 1));

      if (req.parity_type) begin
        parity_bit = ~parity_bit;
      end

      vif.UART_RX = parity_bit;
      rsp.parity  = parity_bit;

      #(bit_period);

    end

    // ----------------------------------------------------------
    // Stop Bit(s)
    // ----------------------------------------------------------

    vif.UART_RX = 1'b1;

    // First stop bit.
    #(bit_period);

    // Optional second stop bit.
    if (req.extra_stop) begin
      vif.UART_RX = 1'b1;
      #(bit_period);
    end

    // ----------------------------------------------------------
    // Return To Idle
    // ----------------------------------------------------------

    vif.UART_RX = 1'b1;

  endtask : drive_uart_frame

endclass : uart_driver

`endif
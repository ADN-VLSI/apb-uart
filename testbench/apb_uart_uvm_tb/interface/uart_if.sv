`ifndef __GUARD_UART_IF_SV__
`define __GUARD_UART_IF_SV__ 0

// UART interface: one serial line, with tasks to send and receive frames.
// Use one instance per line (one for the DUT's TX line, one for its RX line).
interface uart_if;

  // Bit times are calculated in nanoseconds, so fix the time unit here
  timeunit 1ns;
  timeprecision 1ps;

  // --------------------------------------------------------------------------
  // Serial line
  //   - the testbench drives it only while sending (drive_en = 1)
  //   - otherwise it is released and pulled high (idle)
  //   - for the DUT's TX line, the DUT drives it and the testbench only listens
  // --------------------------------------------------------------------------
  logic drive_en  = 1'b0;
  logic drive_val = 1'b1;
  tri1  line;
  assign line = drive_en ? drive_val : 1'bz;

  // --------------------------------------------------------------------------
  // Line settings used by send() and recv()
  // send() stores the settings it was given, so the monitor on the same
  // interface decodes frames with the same settings.
  // Defaults: 115200 baud, no parity, one stop bit, 8 data bits.
  // --------------------------------------------------------------------------
  int baud_rate    = 115200;
  bit parity_en    = 0;
  bit parity_type  = 0;   // 0 = even parity, 1 = odd parity
  bit extra_stop   = 0;   // 1 = two stop bits
  int data_bits    = 8;

  // Set while a frame is being sent / received
  bit sending   = 0;
  bit receiving = 0;

  // --------------------------------------------------------------------------
  // Reset: release the line and clear the busy flags
  // --------------------------------------------------------------------------
  task automatic apply_reset();
    drive_en  = 1'b0;
    drive_val = 1'b1;
    sending   = 1'b0;
    receiving = 1'b0;
  endtask

  // --------------------------------------------------------------------------
  // Driver side: send one UART frame
  //   start bit (0), data bits (LSB first), optional parity bit, stop bit(s) (1)
  // --------------------------------------------------------------------------
  task automatic send(
    input logic [7:0] data,
    input int         baud,
    input bit         par_en,
    input bit         par_type,
    input bit         stop2,
    input int         nbits
  );
    real bit_time;
    bit  parity_bit;

    // Remember the settings
    baud_rate   = baud;
    parity_en   = par_en;
    parity_type = par_type;
    extra_stop  = stop2;
    data_bits   = nbits;

    // Time of one bit in ns
    bit_time = 1.0e9 / baud;

    // Even parity bit = XOR of the data bits; odd parity is the opposite
    parity_bit = 0;
    for (int i = 0; i < nbits; i++) parity_bit ^= data[i];
    if (par_type) parity_bit = ~parity_bit;

    sending  = 1;
    drive_en = 1;

    // Start bit
    drive_val = 1'b0;
    #(bit_time);

    // Data bits, LSB first
    for (int i = 0; i < nbits; i++) begin
      drive_val = data[i];
      #(bit_time);
    end

    // Parity bit (only if enabled)
    if (par_en) begin
      drive_val = parity_bit;
      #(bit_time);
    end

    // Stop bit(s)
    drive_val = 1'b1;
    #(bit_time);
    if (stop2) #(bit_time);

    // Release the line
    drive_en = 0;
    sending  = 0;
  endtask

  // --------------------------------------------------------------------------
  // Monitor side: wait for one UART frame on the line and decode it.
  // Each bit is sampled in the middle of the bit.
  // --------------------------------------------------------------------------
  task automatic recv(output logic [7:0] data, output bit parity);
    real bit_time;

    data   = '0;
    parity = 0;

    // Wait for an idle line, then for the falling edge of the start bit
    wait (line === 1'b1);
    @(negedge line);
    receiving = 1;

    // Read the settings now, because send() may have just changed them
    bit_time = 1.0e9 / baud_rate;

    // Move to the middle of the start bit
    #(bit_time / 2.0);

    // Data bits, LSB first
    for (int i = 0; i < data_bits; i++) begin
      #(bit_time);
      data[i] = line;
    end

    // Parity bit (only if enabled)
    if (parity_en) begin
      #(bit_time);
      parity = line;
    end

    // Stop bit(s): finish in the middle of the last one
    #(bit_time);
    if (extra_stop) #(bit_time);

    receiving = 0;
  endtask

  // --------------------------------------------------------------------------
  // Wait until nothing is being sent or received and the line has been
  // idle (high) for x bit times in a row
  // --------------------------------------------------------------------------
  task automatic wait_till_idle(int x = 10);
    real bit_time;
    int  idle_bits = 0;

    bit_time = 1.0e9 / baud_rate;

    while (idle_bits < x) begin
      #(bit_time);
      if (sending || receiving || line !== 1'b1) idle_bits = 0;
      else idle_bits++;
    end
  endtask

endinterface

`endif

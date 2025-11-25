// -----------------------------------------------------------------------------
// edge_detector.sv
//
// Simple edge detector for a single signal. Detects rising/falling edges by
// sampling the input signal on the local clock and comparing the current value
// to the previous value stored in a register. When a rising edge is detected,
// `rising_edge_o` is asserted. When a falling edge is detected,
// `falling_edge_o` is asserted.
// -----------------------------------------------------------------------------
module edge_detector (
  input  logic clk_i,        // Clock input (rising-edge triggered)
  input  logic arst_ni,      // Asynchronous active-low reset (synchronous deassertion)
  input  logic signal_i,     // Signal to detect edges on (should be synchronous to clk_i)
  output logic rising_edge_o,// Asserted when a rising edge is detected
  output logic falling_edge_o// Asserted when a falling edge is detected
);

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Internal Signals
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Registered (delayed) version of `signal_i` sampled at `clk_i`. This
  // provides the previous sample used to detect edges by comparison with the
  // current `signal_i`.
  logic signal_dly;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Combinational Logic
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Combinational comparison between the current `signal_i` and the delayed
  // sample `signal_dly` to detect transitions:
  //  - rising_edge_o: asserted when current is 1 and previous was 0
  //  - falling_edge_o: asserted when current is 0 and previous was 1
  assign rising_edge_o  = signal_i & ~signal_dly;
  assign falling_edge_o = ~signal_i & signal_dly;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Sequential Logic
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Always block samples `signal_i` into `signal_dly` at every clock `clk_i`.
  // The asynchronous reset clears the delayed value to a known state (0).
  // Note: `always_ff` is used for sequential logic to make intent explicit.
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) signal_dly <= 1'b0;
    else signal_dly <= signal_i; // sample the input for next cycle comparison
  end

endmodule

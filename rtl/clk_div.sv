// Simple frequency divider / clock generator
//
// This module divides the input clock by a configurable amount. The output
// `clk_o` toggles whenever the internal `counter_q` is zero which effectively
// produces a clock with a period of 2*div_i (i.e. output frequency is
// clk_i / (2 * div_i)). Special-case: when `div_i` is zero, the counter is
// held at 0 and `clk_o` toggles every input clock, producing clk_i/2.
//
// Parameters:
//  - DIV_WIDTH: width (in bits) of the divider register/port. It describes
//    how large `div_i` can be. A larger width supports larger division
//    ratios.
module clk_div #(
  parameter int DIV_WIDTH = 4
) (
    // Active-low asynchronous reset (arst_ni). When pulled low, internal
    // registers are reset to their default values.
    input  logic                 arst_ni,

    // Input clock to divide.
    input  logic                 clk_i,

    // Divider value. Controls the number of input clock cycles between
    // output toggles. When div_i is 0, special-case behavior applies and the
    // output toggles every input clock (clk_i/2).
    input  logic [DIV_WIDTH-1:0] div_i,

    // Output divided clock.
    output logic                 clk_o
);

  // Internal counter holding the current count value
  logic [DIV_WIDTH-1:0] counter_q;

  // Next-state value for the counter. Calculated combinatorially from
  // `counter_q` and the requested `div_i` (wrap-around behavior is handled
  // here so the sequential block can simply assign the next state).
  logic [DIV_WIDTH-1:0] counter_n;

  // When `toggle_en` is true, `clk_o` will toggle on the next clock edge.
  // This signal is asserted when the counter equals zero (i.e., once every
  // `div_i` cycles). For div_i == 0, toggle_en will be asserted every cycle.
  logic                 toggle_en;

  // Determine whether to toggle the output: true only when the counter is
  // zero. This implements the toggle-on-wrap behavior for the divider.
  always_comb toggle_en = (counter_q == '0);

  // Compute the next counter value. If `div_i` is zero, keep the counter at
  // zero; otherwise increment and wrap to zero when reaching `div_i`.
  always_comb begin
    if (div_i == '0) begin
      // With div_i == 0, hold counter at zero and rely on `toggle_en` being
      // true every cycle to produce a clk_i/2 output.
      counter_n = '0;
    end else begin
      // Normal increment-and-wrap behavior. Increment the counter and reset
      // it to zero when it reaches or exceeds `div_i`.
      counter_n = counter_q + 1;
      if (counter_n >= div_i) begin
        counter_n = '0;
      end
    end
  end

  // Sequential update of the counter on the input clock. Reset is active-low
  // asynchronous as signaled by `arst_ni`.
  always @(clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      counter_q <= '0;
    end else begin
      counter_q <= counter_n;
    end
  end

  // Output clock toggling logic. Toggle on `toggle_en` edges; reset to a
  // known state on `arst_ni` deassertion.
  always @(clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      clk_o <= '0;
    end else begin
      if (toggle_en) begin
        // Flip the output whenever toggle_en is asserted.
        clk_o <= ~clk_o;
      end
    end
  end
endmodule

// UART Receiver Module
// This module implements a UART receiver that samples incoming serial data
// at the specified baud rate, assembles bytes, checks parity if enabled,
// and outputs valid data with error flags.
module uart_rx
  import uart_rx_pkg::*;  // Import package with state and parameter definitions
(
    input logic arst_ni,         // Asynchronous reset, active low
    input logic clk_i,           // Clock input

    input logic rx_i,            // Serial RX input line

    input logic parity_en_i,     // Enable parity checking
    input logic parity_type_i,   // Parity type: 0=even, 1=odd

    output logic [7:0] data_o,   // Received 8-bit data
    output logic       data_valid_o,  // Data valid pulse

    output logic parity_error_o  // Parity error flag
);

  // --------------------------------------------------------------------------
  // Parameters: BitTicks sets number of clk cycles per data bit.
  // HalfBitTicks used to sample mid of start bit.
  // --------------------------------------------------------------------------
  parameter int BitTicks = 8;  // clock cycles per bit (configurable for baud rate)
  localparam int HalfBitTicks = BitTicks / 2;  // Half bit time for start bit sampling
  localparam int TickCntWidth = (BitTicks > 1) ? $clog2(BitTicks) : 1;  // Counter width

  // --------------------------------------------------------------------------
  // Signals
  // --------------------------------------------------------------------------
  uart_rx_state_e state;  // Current FSM state
  logic edge_found;  // Pulse indicating bit sampling time
  logic [TickCntWidth-1:0] tick_cnt;  // Counter for bit timing
  logic rx_q;  // Synchronized RX input
  logic start_edge;  // Falling edge detection for start bit
  logic [7:0] data_shift;  // Shift register for assembling data bits
  logic parity_bit_sampled;  // Sampled parity bit
  logic parity_ok;  // Parity check result
  logic data_parity;  // Calculated parity from data

  // Parity calculation: XOR of all data bits (even parity base)
  assign data_parity = ^data_shift;

  // Output assignments
  assign data_o = data_shift;
  assign parity_error_o = parity_en_i && !parity_ok;  // Error only if parity enabled and failed

  // --------------------------------------------------------------------------
  // Synchronize / register rx for edge detection
  // --------------------------------------------------------------------------
  // Register RX input to avoid metastability
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      rx_q <= 1'b1;  // Idle line is high
    end else begin
      rx_q <= rx_i;
    end
  end

  // Detect falling edge on RX while in IDLE (start of frame)
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      start_edge <= 1'b0;
    end else begin
      start_edge <= (rx_q == 1'b1) && (rx_i == 1'b0) && (state == IDLE);
    end
  end

  // --------------------------------------------------------------------------
  // Bit timing generator producing edge_found pulses.
  // - In IDLE: wait for falling edge to start.
  // - In START_BIT: generate single pulse after HALF_BIT_TICKS.
  // - In other states: pulse every BIT_TICKS.
  // --------------------------------------------------------------------------
  // Counter for bit timing
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      tick_cnt <= '0;
    end else begin
      if (state == IDLE) begin
        tick_cnt <= '0;  // Reset in idle
      end else begin
        if (edge_found) begin
          tick_cnt <= '0;  // Reset on edge
        end else begin
          tick_cnt <= tick_cnt + 1'b1;  // Count up
        end
      end
    end
  end

  // Generate edge_found pulse at appropriate times
  always_comb begin
    if (state == IDLE) begin
      edge_found = start_edge;  // Trigger on start edge
    end else begin
      edge_found = (tick_cnt == ((state == START_BIT) ? HalfBitTicks : BitTicks) - 1);
    end
  end

  // --------------------------------------------------------------------------
  // FSM instantiation
  // --------------------------------------------------------------------------
  uart_rx_fsm u_fsm (
      .arst_ni    (arst_ni),
      .clk_i      (clk_i),
      .edge_found (edge_found),
      .parity_en_i(parity_en_i),
      .dmux_sel_o (state)
  );

  // --------------------------------------------------------------------------
  // Data bit capture on sampling edge
  // --------------------------------------------------------------------------
  // Shift in data bits as they are sampled
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      data_shift <= '0;
    end else begin
      if (edge_found) begin
        case (state)
          DATA_0:  data_shift[0] <= rx_i;
          DATA_1:  data_shift[1] <= rx_i;
          DATA_2:  data_shift[2] <= rx_i;
          DATA_3:  data_shift[3] <= rx_i;
          DATA_4:  data_shift[4] <= rx_i;
          DATA_5:  data_shift[5] <= rx_i;
          DATA_6:  data_shift[6] <= rx_i;
          DATA_7:  data_shift[7] <= rx_i;
          default: ;  // No action for other states
        endcase
      end
    end
  end

  // --------------------------------------------------------------------------
  // Parity sampling and check
  // --------------------------------------------------------------------------
  // Sample parity bit and check against calculated parity
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      parity_bit_sampled <= 1'b0;
      parity_ok <= 1'b1;  // Default to OK on reset
    end else begin
      if (parity_en_i && edge_found && state == PARITY_BIT) begin
        parity_bit_sampled <= rx_i;
        // Check parity: even (rx_i == data_parity) or odd (rx_i == ~data_parity)
        parity_ok <= parity_type_i ? (rx_i == ~data_parity) : (rx_i == data_parity);
      end
      // If parity disabled, parity_ok remains default (no error)
    end
  end

  // --------------------------------------------------------------------------
  // Data valid generation: pulse when STOP_BIT sampled correctly.
  // Requires stop bit high and parity OK (or parity disabled).
  // --------------------------------------------------------------------------
  // Generate data_valid pulse on successful frame reception
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      data_valid_o <= 1'b0;
    end else begin
      if (edge_found && state == STOP_BIT) begin
        // Valid if stop bit is high and parity is OK (or disabled)
        if (rx_i && (parity_en_i ? parity_ok : 1'b1)) begin
          data_valid_o <= 1'b1;
        end else begin
          data_valid_o <= 1'b0;
        end
      end else begin
        data_valid_o <= 1'b0;  // Single-cycle pulse
      end
    end
  end

endmodule


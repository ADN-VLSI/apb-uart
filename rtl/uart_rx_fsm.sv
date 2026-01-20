// UART RX Finite State Machine
// This module implements the FSM for UART receive operations.
// It sequences through the UART frame: start bit, data bits, optional parity, stop bit.
// Transitions occur on bit edge detections, advancing the state for sampling.
module uart_rx_fsm
  import uart_rx_pkg::*;  // Import package with state definitions

(
    input logic arst_ni,                // Asynchronous reset, active low
    input logic clk_i,                  // Clock input

    input logic edge_found,             // Pulse indicating a bit edge (for state transition)

    input logic parity_en_i,            // Parity enable flag

    output uart_rx_state_e dmux_sel_o   // Current state output (used for demux selection)
);

  uart_rx_state_e dmux_sel_next;       // Next state signal

  // --------------------------------------------------------------------------
// Next-state logic
  // Transitions on edge_found pulse. D7→PARITY conditional on parity_en_i.
  // --------------------------------------------------------------------------
  always_comb begin : blockName
    dmux_sel_next = dmux_sel_o;  // Default: stay in current state
    unique case (dmux_sel_o)
      IDLE: begin
        if (edge_found) dmux_sel_next = START_BIT;  // Start on RX line falling edge
      end
      START_BIT: begin
        if (edge_found) dmux_sel_next = DATA_0;  // Move to first data bit
      end
      DATA_0: begin
        if (edge_found) dmux_sel_next = DATA_1;
      end
      DATA_1: begin
        if (edge_found) dmux_sel_next = DATA_2;
      end
      DATA_2: begin
        if (edge_found) dmux_sel_next = DATA_3;
      end
      DATA_3: begin
        if (edge_found) dmux_sel_next = DATA_4;
      end
      DATA_4: begin
        if (edge_found) dmux_sel_next = DATA_5;
      end
      DATA_5: begin
        if (edge_found) dmux_sel_next = DATA_6;
      end
      DATA_6: begin
        if (edge_found) dmux_sel_next = DATA_7;
      end
      DATA_7: begin
        if (edge_found) begin
          dmux_sel_next = parity_en_i ? PARITY_BIT : STOP_BIT;  // Conditional on parity
        end
      end
      PARITY_BIT: begin
        if (edge_found) dmux_sel_next = STOP_BIT;   // After parity, to stop bit
      end
      STOP_BIT: begin
        if (edge_found) dmux_sel_next = IDLE;       // Frame complete, back to idle
      end
      default: dmux_sel_next = IDLE;               // Safety default
    endcase
  end

  // State register: update on clock, reset to IDLE
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      dmux_sel_o <= IDLE;
    end else begin
      dmux_sel_o <= dmux_sel_next;
    end
  end

endmodule


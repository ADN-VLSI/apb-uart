// UART TX Finite State Machine
// Controls the transmission sequence: idle, start bit, data bits, parity (optional), stop bits.
// Transitions through states based on data validity and configuration.
module uart_tx_fsm
  import uart_tx_pkg::*;  // Import package with state definitions
(
    input logic arst_ni,         // Asynchronous reset, active low
    input logic clk_i,           // Clock input

    input  logic data_valid_i,   // Data valid signal from FIFO
    output logic data_ready_o,   // Ready to accept new data

    input logic parity_en_i,     // Parity enable
    input logic extra_stop_i,    // Extra stop bit enable

    output uart_tx_state_e mux_sel_o  // Current state for mux selection
);

  uart_tx_state_e mux_sel_next;  // Next state

  // Combinational logic for next state calculation
  always_comb begin : blockName
    mux_sel_next = mux_sel_o;  // Default: stay in current state
    case (mux_sel_o)
      IDLE: begin
        if (data_valid_i) begin  // If data is available, start transmission
          mux_sel_next = START_BIT;
        end
      end

      START_BIT: begin  // After start bit, send LSB
        mux_sel_next = DATA_0;
      end

      DATA_0: begin  // Data bit 0
        mux_sel_next = DATA_1;
      end

      DATA_1: begin  // Data bit 1
        mux_sel_next = DATA_2;
      end

      DATA_2: begin  // Data bit 2
        mux_sel_next = DATA_3;
      end

      DATA_3: begin  // Data bit 3
        mux_sel_next = DATA_4;
      end

      DATA_4: begin  // Data bit 4
        mux_sel_next = DATA_5;
      end

      DATA_5: begin  // Data bit 5
        mux_sel_next = DATA_6;
      end

      DATA_6: begin  // Data bit 6
        mux_sel_next = DATA_7;
      end

      DATA_7: begin  // After MSB, check parity
        if (parity_en_i) begin
          mux_sel_next = PARITY_BIT;
        end else begin
          mux_sel_next = STOP_BIT;
        end
      end

      PARITY_BIT: begin  // After parity, go to stop
        mux_sel_next = STOP_BIT;
      end

      STOP_BIT: begin  // After stop, check for extra stop
        if (extra_stop_i) begin
          mux_sel_next = EXTRA_STOP;
        end else begin
          mux_sel_next = IDLE;  // Transmission complete
        end
      end

      EXTRA_STOP: begin  // After extra stop, back to idle
        mux_sel_next = IDLE;
      end

      default: begin  // Safety: go to idle
        mux_sel_next = IDLE;
      end
    endcase
  end

  // Data ready when in STOP_BIT state (ready for next byte)
  always_comb begin
    data_ready_o = (mux_sel_o == STOP_BIT);
  end

  // Sequential state update
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      mux_sel_o <= IDLE;  // Reset to idle
    end else begin
      mux_sel_o <= mux_sel_next;  // Update to next state
    end
  end

endmodule

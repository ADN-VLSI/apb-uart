// UART Transmitter Module
// Serializes 8-bit data into UART frame: start bit, data bits, optional parity, stop bits.
// Uses FSM to control transmission timing and bit selection.
module uart_tx
  import uart_tx_pkg::*;  // Import package with state and type definitions
(
    input logic arst_ni,         // Asynchronous reset, active low
    input logic clk_i,           // Clock input (8x baud rate)

    input  logic [7:0] data_i,   // 8-bit data to transmit
    input  logic       data_valid_i,  // Data valid signal
    output logic       data_ready_o,  // Ready for next data

    input logic parity_en_i,     // Enable parity bit
    // input logic     parity_type_i,   // REMOVE if not needed (parity type, e.g., even/odd)
    input logic extra_stop_i,    // Enable extra stop bit

    output logic tx_o            // UART TX output
);

  // -----------------------------
  // FSM
  // Finite State Machine controls transmission sequence
  // -----------------------------
  uart_tx_state_e mux_sel;

  uart_tx_fsm u_fsm (
      .arst_ni(arst_ni),
      .clk_i  (clk_i),

      .data_valid_i(data_valid_i),
      .data_ready_o(data_ready_o),

      .parity_en_i (parity_en_i),
      .extra_stop_i(extra_stop_i),

      .mux_sel_o(mux_sel)
  );

  // --------------------------------
  // Bit Bank (from diagram)
  // Stores fixed bits and data for transmission
  // --------------------------------
  logic start_bit;       // Always 0
  logic stop_bit;        // Always 1
  logic extra_stop_bit;  // Always 1
  logic parity_bit;      // Computed parity

  logic [7:0] data_reg;  // Registered data

  // Load the data and compute parity once at start of transmission
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      data_reg   <= 8'h00;
      parity_bit <= 1'b0;
    end else begin
      if (mux_sel == IDLE && data_valid_i) begin  // Load when idle and data available
        data_reg   <= data_i;

        // Even parity by default (XOR of all data bits)
        parity_bit <= ^data_i;  // You can remove parity_type if not needed
      end
    end
  end

  // Assign fixed bit values
  assign start_bit      = 1'b0;
  assign stop_bit       = 1'b1;
  assign extra_stop_bit = 1'b1;

  // -----------------------------
  // MUX Controlled by FSM
  // Selects which bit to transmit based on current state
  // -----------------------------
  always_comb begin
    unique case (mux_sel)
      START_BIT: tx_o = start_bit;  // Transmit start bit (0)

      DATA_0: tx_o = data_reg[0];  // LSB first
      DATA_1: tx_o = data_reg[1];
      DATA_2: tx_o = data_reg[2];
      DATA_3: tx_o = data_reg[3];
      DATA_4: tx_o = data_reg[4];
      DATA_5: tx_o = data_reg[5];
      DATA_6: tx_o = data_reg[6];
      DATA_7: tx_o = data_reg[7];  // MSB

      PARITY_BIT: tx_o = parity_en_i ? parity_bit : 1'b1;  // Parity or idle high

      STOP_BIT:   tx_o = stop_bit;      // Stop bit (1)
      EXTRA_STOP: tx_o = extra_stop_bit; // Extra stop bit (1)

      default: tx_o = 1'b1;  // Idle state: high
    endcase
  end

endmodule

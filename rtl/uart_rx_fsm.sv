module uart_rx_fsm
  import uart_rx_pkg::*;

(
    input logic arst_ni,
    input logic clk_i,

    input logic edge_found,

    input logic parity_en_i,

    output uart_rx_state_e dmux_sel_o

);

  uart_rx_state_e dmux_sel_next;

  // --------------------------------------------------------------------------
  // Next-state logic
  // Transitions on edge_found pulse. D7→PARITY conditional on parity_en_i.
  // --------------------------------------------------------------------------
  always_comb begin : blockName
    dmux_sel_next = dmux_sel_o;
    unique case (dmux_sel_o)
      IDLE: begin
        if (edge_found) dmux_sel_next = START_BIT;
      end
      START_BIT: begin
        if (edge_found) dmux_sel_next = DATA_0;
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
          dmux_sel_next = parity_en_i ? PARITY_BIT : STOP_BIT;
        end
      end
      PARITY_BIT: begin
        if (edge_found) dmux_sel_next = STOP_BIT;
      end
      STOP_BIT: begin
        if (edge_found) dmux_sel_next = IDLE;
      end
      default: dmux_sel_next = IDLE;
    endcase
  end

  // State register
  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (!arst_ni) begin
      dmux_sel_o <= IDLE;
    end else begin
      dmux_sel_o <= dmux_sel_next;
    end
  end


endmodule


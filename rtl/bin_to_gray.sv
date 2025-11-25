//------------------------------------------------------------------------------
// Module: bin_to_gray
// Description: Convert a binary value to Gray code.
//
// Parameter:
//   - DATA_WIDTH: width of the input/output vectors (default 4)
//
// Ports:
//   - data_in_i  : binary input vector
//   - data_out_o : Gray code output vector
//
// Implementation notes:
//   The MSB of the Gray code is equal to the MSB of the binary input.
//   For other bits i (0..DATA_WIDTH-2), G[i] = B[i+1] ^ B[i].
//------------------------------------------------------------------------------
module bin_to_gray #(
    parameter int DATA_WIDTH = 4
) (
    // Input: binary number to be converted
    input logic [DATA_WIDTH-1:0] data_in_i,

    // Output: Gray code corresponding to the input binary number
    output logic [DATA_WIDTH-1:0] data_out_o
);

  // For bits 0..(DATA_WIDTH-2): Gray bit = XOR of adjacent binary bits
  // i.e., G[i] = B[i+1] ^ B[i]
  for (genvar i = 0; i < (DATA_WIDTH - 1); i++) begin : g_lsb
    assign data_out_o[i] = data_in_i[1+i] ^ data_in_i[i];
  end

  // The MSB of Gray code equals MSB of binary input
  assign data_out_o[DATA_WIDTH-1] = data_in_i[DATA_WIDTH-1];

endmodule

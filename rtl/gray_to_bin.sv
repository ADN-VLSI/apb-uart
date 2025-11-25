//------------------------------------------------------------------------------
// Module: gray_to_bin
// Description: Convert a Gray-coded value to the corresponding binary number.
//
// Parameter:
//   - DATA_WIDTH: width of the input/output vectors (default 4)
//
// Ports:
//   - data_in_i  : Gray code input vector
//   - data_out_o : converted binary output vector
//
// Implementation notes:
//   The MSB of the binary output B[MSB] is equal to the Gray MSB G[MSB].
//   Lower bits are reconstructed by: B[i] = B[i+1] ^ G[i], which results in
//   B[i] = G[i] ^ G[i+1] ^ ... ^ G[MSB] when fully expanded.
//------------------------------------------------------------------------------
module gray_to_bin #(
    parameter int DATA_WIDTH = 4
) (
    // Input: Gray code to be converted
    input logic [DATA_WIDTH-1:0] data_in_i,

    // Output: Binary representation corresponding to the Gray-coded input
    output logic [DATA_WIDTH-1:0] data_out_o
);

  // For bits 0..(DATA_WIDTH-2): compute B[i] as XOR of computed B[i+1]
  // and current Gray bit G[i]. This effectively means
  // B[i] = G[i] ^ G[i+1] ^ ... ^ G[MSB] (implemented sequentially)
  for (genvar i = 0; i < (DATA_WIDTH - 1); i++) begin : g_lsb
    assign data_out_o[i] = data_out_o[1+i] ^ data_in_i[i];
  end

  // MSB directly mapped from Gray MSB
  assign data_out_o[DATA_WIDTH-1] = data_in_i[DATA_WIDTH-1];

endmodule

module apb_uart_sanity_check_tb;

  localparam int ADDR_WIDTH = 5;
  localparam int DATA_WIDTH = 32;

  logic arst_ni;
  logic clk_i;

  logic rx_i;
  logic tx_o;

  apb_intf #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_apb_if (
      .arst_ni(arst_ni),
      .clk_i  (clk_i)
  );

  uart_top #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_dut (
      .arst_ni            (arst_ni),
      .clk_i              (clk_i),
      .psel_i             (u_apb_if.psel),
      .penable_i          (u_apb_if.penable),
      .paddr_i            (u_apb_if.paddr),
      .pwrite_i           (u_apb_if.pwrite),
      .pwdata_i           (u_apb_if.pwdata),
      .pstrb_i            (u_apb_if.pstrb),
      .pready_o           (u_apb_if.pready),
      .prdata_o           (u_apb_if.prdata),
      .pslverr_o          (u_apb_if.pslverr),
      .rx_i               (rx_i),
      .tx_o               (tx_o),
      .irq_tx_almost_full (),
      .irq_rx_almost_full (),
      .irq_rx_parity_error(),
      .irq_rx_valid       ()
  );

  assign rx_i = tx_o;  // Loopback for sanity check

  task automatic reset_dut();
    #100ns;
    arst_ni <= 1'b0;
    clk_i   <= 1'b0;
    u_apb_if.reset();
    #100ns;
    arst_ni <= 1'b1;
    #100ns;
  endtask

  task automatic clock_gen();
    fork
      forever #5ns clk_i <= ~clk_i;
    join_none
  endtask

  initial begin
    int my_data;
    $dumpfile("apb_uart_sanity_check_tb.vcd");
    $dumpvars(0, apb_uart_sanity_check_tb);

    reset_dut();
    clock_gen();

    // Enabling UART with Defaults
    u_apb_if.write('h00, 32'h0000_0001);  // Enable UART
    u_apb_if.write('h04, 32'd868);  // Clock Divider for 115200 baud rate assuming 100MHz clock

    // Transmit a byte
    u_apb_if.write('h14, 32'h0000_0055);  // Write data to TX FIFO 1 0101 0101 0
    u_apb_if.write('h14, 32'h0000_00AA);  // Write data to TX FIFO 1 1010 1010 0
    u_apb_if.write('h14, 32'h0000_00FC);  // Write data to TX FIFO 1 1111 1100 0

    #5ms;

    repeat (3) begin
      u_apb_if.read('h18, my_data);  // Read TX FIFO Status
      $display("TX FIFO Status after writes: 0x%08h", my_data);
    end

    #1ms;

    $finish;
  end

endmodule

module apb_uart_tb;
  import uvm_pkg::*;
  import apb_uart_uvm_pkg::*;

  logic PCLK=0;
  always #5 PCLK=~PCLK;

  apb_uart_if apb_if(PCLK);
  apb_req_t apb_req;
  apb_resp_t apb_resp;

  assign apb_req.psel    = apb_if.psel;
  assign apb_req.penable = apb_if.penable;
  assign apb_req.paddr   = apb_if.paddr;
  assign apb_req.pwrite  = apb_if.pwrite;
  assign apb_req.pwdata  = apb_if.pwdata;
  assign apb_if.prdata   = apb_resp.prdata;
  assign apb_if.pready   = apb_resp.pready;
  assign apb_if.pslverr  = apb_resp.pslverr;

  apb_uart_top dut (
    .PCLK(PCLK), .PRESETn(apb_if.PRESETn),
    .apb_req_i(apb_req), .apb_resp_o(apb_resp),
    .UART_TX(apb_if.UART_TX), .UART_RX(apb_if.UART_RX),
    .UART_IRQ(apb_if.UART_IRQ)
  );

  initial begin
    apb_if.PRESETn=0;
    apb_if.drive_idle();
    apb_if.UART_RX=1;
    repeat (5) @(negedge PCLK);
    apb_if.PRESETn=1;
  end

  initial begin
    string test_name;

    uvm_config_db#(virtual apb_uart_if)::set(null,"*","vif",apb_if);
    uvm_config_db#(int unsigned)::set(null,"*","clocks_per_bit",16);
    if (!$value$plusargs("TN=%s", test_name) || test_name == "default")
      test_name = "apb_uart_base_test";
    run_test(test_name);
  end
endmodule
`include "apb_uart_pkg.sv"

module apb_uart_uvm_tb;
  import uvm_pkg::*;
  import apb_uart_pkg::*;

  logic pclk = 1'b0;
  logic presetn = 1'b0;
  logic uart_tx;
  logic uart_irq;
  apb_req_t apb_req;
  apb_resp_t apb_resp;

  always #5ns pclk = ~pclk;

  apb_if bus(pclk, presetn);

  always_comb begin
    apb_req.psel = bus.psel;
    apb_req.penable = bus.penable;
    apb_req.paddr = bus.paddr;
    apb_req.pprot = '0;
    apb_req.pwrite = bus.pwrite;
    apb_req.pwdata = bus.pwdata;
    apb_req.pstrb = bus.pstrb;
    bus.pready = apb_resp.pready;
    bus.prdata = apb_resp.prdata;
    bus.pslverr = apb_resp.pslverr;
  end

  apb_uart_top dut (
      .PCLK(pclk),
      .PRESETn(presetn),
      .apb_req_i(apb_req),
      .apb_resp_o(apb_resp),
      .UART_TX(uart_tx),
      .UART_RX(1'b1),
      .UART_IRQ(uart_irq)
  );

  initial begin
    string test_name;
    bus.psel = 1'b0;
    bus.penable = 1'b0;
    bus.pwrite = 1'b0;
    bus.paddr = '0;
    bus.pwdata = '0;
    bus.pstrb = '0;
    uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", bus);
    if (!$value$plusargs("TN=%s", test_name)) test_name = "basic_read_test";
    run_test(test_name);
  end

  initial begin
    repeat (5) @(posedge pclk);
    @(negedge pclk);
    presetn = 1'b1;
  end
endmodule
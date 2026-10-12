`ifndef __GUARD_APB_UART_TB_TOP_SV__
`define __GUARD_APB_UART_TB_TOP_SV__ 0



`include "uvm_macros.svh"
`include "uart_reg_if_pkg.sv"
`include "apb_uart_uvm_tb/test/basic_write_test.sv"
`include "apb_uart_uvm_tb/test/basic_read_test.sv"
`include "apb_uart_uvm_tb/test/base_test.sv"
`include "apb_uart_uvm_tb/test/all_reg_access_test.sv"



import uvm_pkg::*;

module apb_uart_tb_top;


  import uart_reg_if_pkg::*;

  // ------------------------------------------------------------
  // Clock and Reset Configuration
  // ------------------------------------------------------------

  parameter time CLK_PERIOD = 10ns;

  // ------------------------------------------------------------
  // Interfaces
  // ------------------------------------------------------------

  apb_if  apb_vif();
  uart_if uart_vif();

  // ------------------------------------------------------------
  // APB Request and Response Structures
  // ------------------------------------------------------------

  apb_req_t  apb_req;
  apb_resp_t apb_resp;

  // ------------------------------------------------------------
  // DUT
  // ------------------------------------------------------------

  apb_uart_top #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .FIFO_SIZE (4)
  ) dut (

    // Clock and Reset
    .PCLK    (apb_vif.PCLK),
    .PRESETn (apb_vif.PRESETn),

    // APB Interface
    .apb_req_i  (apb_req),
    .apb_resp_o (apb_resp),

    // UART Interface
    .UART_TX (uart_vif.UART_TX),
    .UART_RX (uart_vif.UART_RX),
import uvm_pkg::*;
    // Interrupt
    .UART_IRQ (uart_vif.UART_IRQ)

  );

  // ------------------------------------------------------------
  // APB Request Structure Mapping
  // ------------------------------------------------------------

  always_comb begin

    apb_req.psel   = apb_vif.psel;
    apb_req.penable = apb_vif.penable;
    apb_req.paddr  = apb_vif.paddr;
    apb_req.pwrite = apb_vif.pwrite;
    apb_req.pwdata = apb_vif.pwdata;

  end

  // ------------------------------------------------------------
  // APB Response Structure Mapping
  // ------------------------------------------------------------

  always_comb begin

    apb_vif.pready = apb_resp.pready;
    apb_vif.prdata = apb_resp.prdata;
    apb_vif.pslverr = apb_resp.pslverr;

  end

  // ------------------------------------------------------------
  // Clock Generation
  // ------------------------------------------------------------

  initial begin

    apb_vif.PCLK = 1'b0;

    forever begin
      #(CLK_PERIOD / 2);
      apb_vif.PCLK = ~apb_vif.PCLK;
    end

  end

  // ------------------------------------------------------------
  // Reset Generation
  // ------------------------------------------------------------

  initial begin

    apb_vif.PRESETn = 1'b0;

    // UART idle state.
    uart_vif.UART_RX = 1'b1;

    // Initialize APB request signals.
    apb_vif.psel    = 1'b0;
    apb_vif.penable = 1'b0;
    apb_vif.paddr   = '0;
    apb_vif.pwrite  = 1'b0;
    apb_vif.pwdata  = '0;

    repeat (10) @(posedge apb_vif.PCLK);

    apb_vif.PRESETn = 1'b1;

  end

  // ------------------------------------------------------------
  // UVM Configuration
  // ------------------------------------------------------------

  initial begin

    // Configure APB virtual interface.
    uvm_config_db#(virtual apb_if)::set(
      null,
      "uvm_test_top.env.apb_agent*",
      "vif",
      apb_vif
    );

    // Configure UART virtual interface.
    uvm_config_db#(virtual uart_if)::set(
      uvm_root::get(),
      "uvm_test_top.env.uart_agent*",
      "vif",
      uart_vif
    );

    // Configure UART monitor defaults.
    uvm_config_db#(int)::set(
      null,
      "uvm_test_top.env.uart_agent.monitor",
      "baud_rate",
      115200
    );

    uvm_config_db#(int)::set(
      null,
      "uvm_test_top.env.uart_agent.monitor",
      "data_bits",
      8
    );

    uvm_config_db#(bit)::set(
      null,
      "uvm_test_top.env.uart_agent.monitor",
      "parity_en",
      0
    );

    uvm_config_db#(bit)::set(
      null,
      "uvm_test_top.env.uart_agent.monitor",
      "parity_type",
      0
    );

    uvm_config_db#(bit)::set(
      null,
      "uvm_test_top.env.uart_agent.monitor",
      "extra_stop",
      0
    );

    // Start the selected UVM test.
    run_test("base_test");

  end

endmodule : apb_uart_tb_top

`endif
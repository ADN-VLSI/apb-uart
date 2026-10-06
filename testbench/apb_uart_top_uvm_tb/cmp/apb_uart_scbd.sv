`ifndef __GUARD_APB_UART_SCBD_SV__
`define __GUARD_APB_UART_SCBD_SV__

`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_uart_tx)
`uvm_analysis_imp_decl(_uart_rx)

class apb_uart_scbd extends uvm_scoreboard;
  `uvm_component_utils(apb_uart_scbd)

  localparam bit [31:0] ADDR_CTRL   = 'h000;
  localparam bit [31:0] ADDR_CFG    = 'h004;
  localparam bit [31:0] ADDR_STATUS = 'h008;
  localparam bit [31:0] ADDR_TXD    = 'h01c;
  localparam bit [31:0] ADDR_RXD    = 'h02c;
  localparam bit [31:0] ADDR_INTR   = 'h030;

  uvm_analysis_imp_apb     #(apb_rsp_item,  apb_uart_scbd) apb_imp;
  uvm_analysis_imp_uart_tx #(uart_rsp_item, apb_uart_scbd) uart_tx_imp;
  uvm_analysis_imp_uart_rx #(uart_rsp_item, apb_uart_scbd) uart_rx_imp;

  bit [7:0] tx_expected_q[$];
  bit [7:0] rx_expected_q[$];
  int unsigned pass_count=0;
  int unsigned fail_count=0;

  function new(string name="apb_uart_scbd", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_imp     = new("apb_imp",this);
    uart_tx_imp = new("uart_tx_imp",this);
    uart_rx_imp = new("uart_rx_imp",this);
  endfunction

  function void write_apb(apb_rsp_item item);
    if (item.error) begin
      `uvm_warning("APB_SCB",$sformatf("APB SLVERR at address 0x%08h",item.addr))
      return;
    end

    if (item.write && item.addr==ADDR_TXD) begin
      tx_expected_q.push_back(item.data[7:0]);
      `uvm_info("APB_SCB",$sformatf("Expect TX byte 0x%02h (queue depth %0d)",item.data[7:0],tx_expected_q.size()),UVM_MEDIUM)
    end else if (!item.write && item.addr==ADDR_RXD) begin
      if (rx_expected_q.size()==0) begin
        fail_count++;
        `uvm_error("APB_SCB",$sformatf("RXD read 0x%02h with no byte observed on UART RX",item.rdata[7:0]))
      end else begin
        bit [7:0] expected;
        expected=rx_expected_q.pop_front();
        if (item.rdata[7:0]===expected) begin
          pass_count++;
          `uvm_info("APB_SCB",$sformatf("RX data matched: 0x%02h",item.rdata[7:0]),UVM_LOW)
        end else begin
          fail_count++;
          `uvm_error("APB_SCB",$sformatf("RX mismatch: expected 0x%02h, got 0x%02h",expected,item.rdata[7:0]))
        end
      end
    end else if (item.write && item.addr==ADDR_CFG) begin
      `uvm_info("APB_SCB",$sformatf("UART config write: 0x%08h",item.data),UVM_HIGH)
    end else if (item.write && item.addr==ADDR_CTRL) begin
      `uvm_info("APB_SCB",$sformatf("UART control write: 0x%08h",item.data),UVM_HIGH)
    end else if (item.write && item.addr==ADDR_INTR) begin
      `uvm_info("APB_SCB",$sformatf("UART interrupt write: 0x%08h",item.data),UVM_HIGH)
    end else if (!item.write && item.addr==ADDR_STATUS) begin
      `uvm_info("APB_SCB",$sformatf("UART status read: 0x%08h",item.rdata),UVM_HIGH)
    end
  endfunction

  function void write_uart_tx(uart_rsp_item item);
    bit [7:0] discarded;
    if (item.framing_error || item.parity_error) begin
      fail_count++;
      `uvm_error("UART_TX_SCB","UART TX monitor reported a framing or parity error")
      // Consume the corresponding expected byte so later transfers stay aligned,
      // but never count a malformed frame as a passing comparison.
      if (tx_expected_q.size()!=0)
        discarded=tx_expected_q.pop_front();
      else
        `uvm_error("UART_TX_SCB",$sformatf("Unexpected malformed UART TX byte 0x%02h",item.data))
      return;
    end
    if (tx_expected_q.size()==0) begin
      fail_count++;
      `uvm_error("UART_TX_SCB",$sformatf("Unexpected UART TX byte 0x%02h",item.data))
    end else begin
      bit [7:0] expected;
      expected=tx_expected_q.pop_front();
      if (item.data===expected) begin
        pass_count++;
        `uvm_info("UART_TX_SCB",$sformatf("TX data matched: 0x%02h",item.data),UVM_LOW)
      end else begin
        fail_count++;
        `uvm_error("UART_TX_SCB",$sformatf("TX mismatch: expected 0x%02h, got 0x%02h",expected,item.data))
      end
    end
  endfunction

  function void write_uart_rx(uart_rsp_item item);
    if (item.framing_error || item.parity_error) begin
      fail_count++;
      `uvm_error("UART_RX_SCB","UART RX driver reported a framing or parity error")
      return;
    end
    rx_expected_q.push_back(item.data);
    `uvm_info("UART_RX_SCB",$sformatf("Expect APB RXD byte 0x%02h (queue depth %0d)",item.data,rx_expected_q.size()),UVM_MEDIUM)
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (tx_expected_q.size()!=0) begin
      fail_count+=tx_expected_q.size();
      `uvm_error("APB_UART_SCB",$sformatf("%0d TX byte(s) were not observed",tx_expected_q.size()))
    end
    if (rx_expected_q.size()!=0) begin
      fail_count+=rx_expected_q.size();
      `uvm_error("APB_UART_SCB",$sformatf("%0d RX byte(s) were not read through APB",rx_expected_q.size()))
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    $display("");
    $display("========================================");
    $display("       FINAL TEST SUMMARY               ");
    $display("========================================");
    $display(" PASS            = %0d",pass_count);
    $display(" FAIL            = %0d",fail_count);
    $display("========================================");
    if (fail_count==0 && pass_count>0 && tx_expected_q.size()==0 && rx_expected_q.size()==0)
      $display(" ALL TESTS PASSED");
    else if (pass_count==0 && fail_count==0)
      $display(" NO TRANSACTIONS CHECKED");
    else
      $display(" SOME TESTS FAILED");
    $display("========================================");

    `uvm_info("APB_UART_SCB","========================================",UVM_NONE)
    `uvm_info("APB_UART_SCB","       FINAL TEST SUMMARY               ",UVM_NONE)
    `uvm_info("APB_UART_SCB","========================================",UVM_NONE)
    `uvm_info("APB_UART_SCB",$sformatf(" PASS            = %0d",pass_count),UVM_NONE)
    `uvm_info("APB_UART_SCB",$sformatf(" FAIL            = %0d",fail_count),UVM_NONE)
    `uvm_info("APB_UART_SCB","========================================",UVM_NONE)
    if (fail_count==0 && pass_count>0 && tx_expected_q.size()==0 && rx_expected_q.size()==0)
      `uvm_info("APB_UART_SCB"," ALL TESTS PASSED",UVM_NONE)
    else if (pass_count==0 && fail_count==0)
      `uvm_warning("APB_UART_SCB"," NO TRANSACTIONS CHECKED")
    else
      `uvm_error("APB_UART_SCB"," SOME TESTS FAILED")
    `uvm_info("APB_UART_SCB","========================================",UVM_NONE)
  endfunction
endclass

`endif

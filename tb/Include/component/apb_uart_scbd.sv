`ifndef __GUARD_APB_UART_SCBD_SV__
`define __GUARD_APB_UART_SCBD_SV__ 0

`include "object/apb_rsp_item.sv"
`include "object/uart_rsp_item.sv"

`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_uart)

class apb_uart_scbd extends uvm_scoreboard;

  `uvm_component_utils(apb_uart_scbd)

  uvm_analysis_imp_apb #(apb_rsp_item, apb_uart_scbd) m_analysis_imp_apb;
  uvm_analysis_imp_uart #(uart_rsp_item, apb_uart_scbd) m_analysis_imp_uart;

  protected apb_rsp_item apb_q[$];
  protected uart_rsp_item uart_q[$];

  protected int pass_count = 0;
  protected int fail_count = 0;

  function new(string name = "apb_uart_scbd", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create an instance of each analysis
    m_analysis_imp_apb  = new($sformatf("m_analysis_imp_apb"), this);
    m_analysis_imp_uart = new($sformatf("m_analysis_imp_uart"), this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  function void write_apb(apb_rsp_item item);
    `uvm_info(get_type_name(), $sformatf("Received APB item: %s", item.sprint()), UVM_HIGH)
    apb_q.push_back(item);
  endfunction

  // Function: write_sum
  // Implementation for the `sum` analysis port. Called by the monitor.
  function void write_uart(uart_rsp_item item);
    `uvm_info(get_type_name(), $sformatf("Received UART item: %s", item.sprint()), UVM_HIGH)
    uart_q.push_back(item);
  endfunction

  task run_phase(uvm_phase phase);

  endtask

  function void report_phase(uvm_phase phase);
    $display("apb_q size: %0d, uart_q size: %0d", apb_q.size(), uart_q.size());

    `uvm_info(get_type_name(), $sformatf("--- Scoreboard Summary ---"), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("Passed: %0d", pass_count), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("Failed: %0d", fail_count), UVM_NONE)
    `uvm_info(get_type_name(), "--------------------------", UVM_NONE)
    if (fail_count > 0) begin
      `uvm_error(get_type_name(), "Test FAILED")
    end else begin
      `uvm_info(get_type_name(), "Test PASSED", UVM_NONE)
    end
  endfunction

endclass

`endif

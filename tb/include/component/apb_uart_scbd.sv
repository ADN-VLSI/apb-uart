// Include guard to prevent multiple inclusions of this file
`ifndef __GUARD_APB_UART_SCBD_SV__
`define __GUARD_APB_UART_SCBD_SV__ 0

// Include response item classes
`include "object/apb_rsp_item.sv"
`include "object/uart_rsp_item.sv"

// Declare analysis implementation ports for APB and UART
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_uart)

// Coverage group for UART transactions
covergroup uart_transactions_cg with function sample(
  input bit       direction,
  input bit [7:0] data,
  input int       baud_rate,
  input bit       parity_enable,
  input bit       parity_type,
  input bit       second_stop_bit
);

  // Coverpoint for direction (transmit/receive)
  direction_cp : coverpoint direction {
    bins tx = {1};
    bins rx = {0};
  }

  // Coverpoint for transmitted/received data
  data_cp : coverpoint data {
    bins all_0s = {'h00};
    bins mixed  = {['h01 : 'h7F ]};
    bins all_1s = {'hff};
  }

  // Coverpoint for baud rate settings
  baud_rate_cp : coverpoint baud_rate {
    bins baud_rate_bins[] = {9600, 19200, 38400, 57600, 115200};
  }

  // Coverpoint for parity enable
  parity_enable_cp : coverpoint parity_enable {
    bins enabled = {1};
    bins disabled = {0};
  }

  // Coverpoint for parity type
  parity_type_cp : coverpoint parity_type {
    bins even = {0};
    bins odd  = {1};
  }

  // Coverpoint for second stop bit
  second_stop_bit_cp : coverpoint second_stop_bit {
    bins one_stop_bit = {0};
    bins two_stop_bits = {1};
  }

  // cross coverage between direction and data
  direction_data_cross : cross direction_cp, data_cp;
  direction_baud_rate_cross : cross direction_cp, baud_rate_cp;
  direction_parity_enable_cross : cross direction_cp, parity_enable_cp;
  direction_parity_type_cross : cross direction_cp, parity_type_cp;
  direction_second_stop_bit_cross : cross direction_cp, second_stop_bit_cp;

endgroup

// APB UART Scoreboard
// This UVM scoreboard compares APB transactions with UART transactions
// to verify data integrity and configuration settings.
class apb_uart_scbd extends uvm_scoreboard;

  // UVM component utilities for factory registration
  `uvm_component_utils(apb_uart_scbd)

  // Analysis implementation ports for receiving items from monitors
  uvm_analysis_imp_apb #(apb_rsp_item, apb_uart_scbd) m_analysis_imp_apb;
  uvm_analysis_imp_uart #(uart_rsp_item, apb_uart_scbd) m_analysis_imp_uart;

  // Queues to store received items
  protected apb_rsp_item apb_q[$];
  protected byte uart_tx_q[$];
  protected byte uart_rx_q[$];

  // Counters for test results
  protected int pass_count = 0;
  protected int fail_count = 0;

  uart_transactions_cg uart_cg;

  // Constructor for the APB UART scoreboard
  function new(string name = "apb_uart_scbd", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  // Build phase: create analysis implementation ports
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create an instance of each analysis implementation
    m_analysis_imp_apb  = new($sformatf("m_analysis_imp_apb"), this);
    m_analysis_imp_uart = new($sformatf("m_analysis_imp_uart"), this);
    // Instantiate the coverage group
    uart_cg = new();
  endfunction

  // Connect phase: no connections needed
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  // Write function for APB analysis port: store APB items
  function void write_apb(apb_rsp_item item);
    `uvm_info(get_type_name(), $sformatf("Received APB item: %s", item.sprint()), UVM_HIGH)
    apb_q.push_back(item);
  endfunction

  // Write function for UART analysis port: store UART items based on direction
  function void write_uart(uart_rsp_item item);
    `uvm_info(get_type_name(), $sformatf("Received UART item: %s", item.sprint()), UVM_HIGH)

    uart_cg.sample(
      item.direction,
      item.data,
      item.baud_rate,
      item.parity_enable,
      item.parity_type,
      item.second_stop_bit
    );

    if (item.direction === '1) begin
      uart_tx_q.push_back(item.data);
    end
    if (item.direction === '0) begin
      uart_rx_q.push_back(item.data);
    end
  endfunction

  // Run phase: process APB items and perform comparisons
  task run_phase(uvm_phase phase);
    forever begin
      apb_rsp_item apb_item;
      // Wait for APB items in the queue
      wait (apb_q.size());
      apb_item = apb_q.pop_front();
      // Handle different APB addresses and operations
      if (apb_item.tx_type == 1 && apb_item.addr == 4) begin
        // Set baud rate configuration
        uvm_config_db#(int)::set(uvm_root::get(), "uart", "baud_rate", (100000000 / apb_item.data));
      end else if (apb_item.tx_type == 1 && apb_item.addr == 8) begin
        // Set parity configuration
        void'(uvm_config_db#(bit)::get(uvm_root::get(), "uart", "parity_type", apb_item.data[1]));
        void'(uvm_config_db#(bit)::get(uvm_root::get(), "uart", "parity_enable", apb_item.data[0]));
        void'(uvm_config_db#(bit)::get(
            uvm_root::get(), "uart", "second_stop_bit", apb_item.data[2]
        ));
      end else if (apb_item.tx_type == 1 && apb_item.addr == 'h14) begin
        // Compare TX data
        byte data;
        wait (uart_tx_q.size());
        data = uart_tx_q.pop_front();
        if (data == apb_item.data[7:0]) begin
          pass_count++;
          `uvm_info(get_type_name(), $sformatf("TX Data Match: 0x%0h", data), UVM_LOW)
        end else begin
          fail_count++;
          `uvm_error(get_type_name(), $sformatf(
                     "TX Data Mismatch: APB 0x%0h, UART 0x%0h", apb_item.data[7:0], data))
        end
      end else if (apb_item.tx_type == 0 && apb_item.addr == 'h18) begin
        // Compare RX data
        byte data;
        wait (uart_rx_q.size());
        data = uart_rx_q.pop_front();
        if (data == apb_item.data[7:0]) begin
          pass_count++;
          `uvm_info(get_type_name(), $sformatf("RX Data Match: 0x%0h", data), UVM_LOW)
        end else begin
          fail_count++;
          `uvm_error(get_type_name(), $sformatf(
                     "RX Data Mismatch: UART 0x%0h, APB 0x%0h", data, apb_item.data[7:0]))
        end
      end
    end

  endtask

  // Report phase: display test results
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("--- Scoreboard Summary ---"), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("Passed: %0d", pass_count), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("Failed: %0d", fail_count), UVM_NONE)
    `uvm_info(get_type_name(), "--------------------------", UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("---- Coverage Summary ----"), UVM_NONE)
    `uvm_info(get_type_name(), $sformatf("UART : %0.2f%%", uart_cg.get_coverage()), UVM_NONE)
    `uvm_info(get_type_name(), "--------------------------", UVM_NONE)

    if (fail_count > 0) begin
      `uvm_error(get_type_name(), "Test FAILED")
    end else begin
      `uvm_info(get_type_name(), "Test PASSED", UVM_NONE)
    end
  endfunction

endclass

`endif

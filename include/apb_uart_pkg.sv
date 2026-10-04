`ifndef APB_UART_PKG_SV
`define APB_UART_PKG_SV

package apb_uart_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // =========================================================================
  // 1. CONSTANTS & REGISTER OFFSETS
  // =========================================================================
  localparam bit [31:0] REG_CTRL_OFFSET = 32'h00;
  localparam bit [31:0] REG_CONFIG_OFFSET = 32'h04;
  localparam bit [31:0] REG_STATUS_OFFSET = 32'h08;
  localparam bit [31:0] REG_TX_DATA_OFFSET = 32'h1C;
  localparam bit [31:0] REG_RX_DATA_OFFSET = 32'h2C;

  // Control register bit masks
  localparam bit [31:0] CTRL_SW_RST_MASK = 32'h0000_0001;
  localparam bit [31:0] CTRL_TX_FLUSH_MASK = 32'h0000_0002;
  localparam bit [31:0] CTRL_RX_FLUSH_MASK = 32'h0000_0004;
  localparam bit [31:0] CTRL_TX_EN_MASK = 32'h0000_0008;
  localparam bit [31:0] CTRL_RX_EN_MASK = 32'h0000_0010;

  // Configuration settings (Standard testbench default: oversample=8, 8-data bits)
  localparam bit [31:0] UART_CONFIG_DEFAULT = 32'h0003_0000;

  // =========================================================================
  // 2. SEQUENCE ITEMS
  // =========================================================================

  // --- APB Sequence Item ---
  class apb_seq_item extends uvm_sequence_item;
    rand bit [31:0] addr;
    rand bit        write;
    rand bit [31:0] wdata;
    rand bit [ 3:0] strb;
    bit      [31:0] rdata;
    bit             slverr;

    `uvm_object_utils_begin(apb_seq_item)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(write, UVM_ALL_ON)
      `uvm_field_int(wdata, UVM_ALL_ON)
      `uvm_field_int(strb, UVM_ALL_ON)
      `uvm_field_int(rdata, UVM_ALL_ON)
      `uvm_field_int(slverr, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "apb_seq_item");
      super.new(name);
      strb = 4'b1111;
    endfunction
  endclass : apb_seq_item

  // --- UART Sequence Item ---
  class uart_seq_item extends uvm_sequence_item;
    rand bit [7:0] data;
    bit            parity_err;
    bit            framing_err;

    `uvm_object_utils_begin(uart_seq_item)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(parity_err, UVM_ALL_ON)
      `uvm_field_int(framing_err, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uart_seq_item");
      super.new(name);
    endfunction
  endclass : uart_seq_item

  // =========================================================================
  // 3. APB AGENT COMPONENTS
  // =========================================================================

  typedef uvm_sequencer#(apb_seq_item) apb_sequencer;

  // --- APB Driver ---
  class apb_driver extends uvm_driver #(apb_seq_item);
    `uvm_component_utils(apb_driver)
    virtual apb_if vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
        `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      // Initialize APB Master lines
      vif.apply_reset(1);
      forever begin
        seq_item_port.get_next_item(req);
        drive_transfer(req);
        seq_item_port.item_done();
      end
    endtask

    virtual task drive_transfer(apb_seq_item trans);
      if (trans.write) begin
        vif.write(trans.addr, trans.wdata);
      end else begin
        vif.read(trans.addr, trans.rdata);
      end
    endtask
  endclass : apb_driver

  // --- APB Monitor ---
  class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)
    virtual apb_if vif;
    uvm_analysis_port #(apb_seq_item) item_collected_port;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      item_collected_port = new("item_collected_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
        `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      apb_seq_item trans;
      forever begin
        trans = apb_seq_item::type_id::create("trans");
        vif.get_transaction(trans.addr, trans.write, trans.wdata, trans.slverr);
        if (!trans.write) begin
          trans.rdata = trans.wdata;  // in get_transaction, data contains read value when write=0
        end
        item_collected_port.write(trans);
      end
    endtask
  endclass : apb_monitor

  // --- APB Agent ---
  class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)
    apb_driver    driver;
    apb_sequencer sequencer;
    apb_monitor   monitor;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      monitor = apb_monitor::type_id::create("monitor", this);
      if (get_is_active() == UVM_ACTIVE) begin
        driver    = apb_driver::type_id::create("driver", this);
        sequencer = apb_sequencer::type_id::create("sequencer", this);
      end
    endfunction

    function void connect_phase(uvm_phase phase);
      if (get_is_active() == UVM_ACTIVE) begin
        driver.seq_item_port.connect(sequencer.seq_item_export);
      end
    endfunction
  endclass : apb_agent

  // =========================================================================
  // 4. UART AGENT COMPONENTS
  // =========================================================================

  typedef uvm_sequencer#(uart_seq_item) uart_sequencer;

  // --- UART Driver (Injects RX stimulus into DUT) ---
  class uart_driver extends uvm_driver #(uart_seq_item);
    `uvm_component_utils(uart_driver)
    virtual uart_if vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
        `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(req);
        vif.send(req.data);
        seq_item_port.item_done();
      end
    endtask
  endclass : uart_driver

  // --- UART Monitor (Observes UART_TX from DUT) ---
  class uart_monitor extends uvm_monitor;
    `uvm_component_utils(uart_monitor)
    virtual uart_if vif;
    uvm_analysis_port #(uart_seq_item) item_collected_port;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      item_collected_port = new("item_collected_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
        `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
      end
    endfunction

    virtual task run_phase(uvm_phase phase);
      int rec_data;
      bit parity;
      uart_seq_item trans;

      forever begin
        vif.recv(rec_data, parity);
        trans = uart_seq_item::type_id::create("trans");
        trans.data = rec_data[7:0];
        item_collected_port.write(trans);
      end
    endtask
  endclass : uart_monitor

  // --- UART Agent ---
  class uart_agent extends uvm_agent;
    `uvm_component_utils(uart_agent)
    uart_driver    driver;
    uart_sequencer sequencer;
    uart_monitor   monitor;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      monitor = uart_monitor::type_id::create("monitor", this);
      if (get_is_active() == UVM_ACTIVE) begin
        driver    = uart_driver::type_id::create("driver", this);
        sequencer = uart_sequencer::type_id::create("sequencer", this);
      end
    endfunction

    function void connect_phase(uvm_phase phase);
      if (get_is_active() == UVM_ACTIVE) begin
        driver.seq_item_port.connect(sequencer.seq_item_export);
      end
    endfunction
  endclass : uart_agent

  // =========================================================================
  // 5. SCOREBOARD
  // =========================================================================

  `uvm_analysis_imp_decl(_apb)
  `uvm_analysis_imp_decl(_uart)

  class apb_uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(apb_uart_scoreboard)

    uvm_analysis_imp_apb #(apb_seq_item, apb_uart_scoreboard) apb_export;
    uvm_analysis_imp_uart #(uart_seq_item, apb_uart_scoreboard) uart_export;

    // Expected queues
    bit [7:0] tx_fifo_q[$];  // Data written via APB, expected on UART TX
    bit [7:0] rx_fifo_q[$];  // Data sent over UART RX, expected to read via APB

    function new(string name, uvm_component parent);
      super.new(name, parent);
      apb_export  = new("apb_export", this);
      uart_export = new("uart_export", this);
    endfunction

    virtual function void write_apb(apb_seq_item item);
      // APB Write to TX register -> Push to expected TX Queue
      if (item.write && item.addr == REG_TX_DATA_OFFSET) begin
        tx_fifo_q.push_back(item.wdata[7:0]);
        `uvm_info("SCBD", $sformatf("Captured APB TX Data Write: 0x%02h", item.wdata[7:0]),
                  UVM_MEDIUM)
      end  // APB Read from RX register -> Pop and compare against expected RX Queue
      else if (!item.write && item.addr == REG_RX_DATA_OFFSET) begin
        if (rx_fifo_q.size() > 0) begin
          bit [7:0] exp = rx_fifo_q.pop_front();
          if (item.rdata[7:0] !== exp) begin
            `uvm_error("SCBD_RX_MISMATCH", $sformatf("RX mismatch! Exp: 0x%02h, Got: 0x%02h", exp,
                                                     item.rdata[7:0]))
          end else begin
            `uvm_info("SCBD_RX_MATCH", $sformatf("RX match: 0x%02h", item.rdata[7:0]), UVM_MEDIUM)
          end
        end else begin
          `uvm_warning("SCBD_RX_EMPTY", "Read from RX FIFO when expected queue was empty")
        end
      end
    endfunction

    virtual function void write_uart(uart_seq_item item);
      // UART line monitor captured a byte from DUT TX -> Pop and verify against expected TX Queue
      if (tx_fifo_q.size() > 0) begin
        bit [7:0] exp = tx_fifo_q.pop_front();
        if (item.data !== exp) begin
          `uvm_error("SCBD_TX_MISMATCH", $sformatf("TX serial mismatch! Exp: 0x%02h, Got: 0x%02h",
                                                   exp, item.data))
        end else begin
          `uvm_info("SCBD_TX_MATCH", $sformatf("TX serial match: 0x%02h", item.data), UVM_MEDIUM)
        end
      end else begin
        `uvm_warning("SCBD_TX_UNEXPECTED", $sformatf(
                     "Unexpected TX byte received on serial: 0x%02h", item.data))
      end
    endfunction
  endclass : apb_uart_scoreboard

  // =========================================================================
  // 6. ENVIRONMENT
  // =========================================================================

  class apb_uart_env extends uvm_env;
    `uvm_component_utils(apb_uart_env)

    apb_agent           m_apb_agent;
    uart_agent          m_uart_rx_agent;  // Drives DUT UART_RX
    uart_agent          m_uart_tx_agent;  // Monitors DUT UART_TX
    apb_uart_scoreboard m_scoreboard;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      m_apb_agent     = apb_agent::type_id::create("m_apb_agent", this);
      m_uart_rx_agent = uart_agent::type_id::create("m_uart_rx_agent", this);

      // TX agent is passive (only monitors UART_TX output from DUT)
      uvm_config_db#(uvm_active_passive_enum)::set(this, "m_uart_tx_agent", "is_active",
                                                   UVM_PASSIVE);
      m_uart_tx_agent = uart_agent::type_id::create("m_uart_tx_agent", this);

      m_scoreboard    = apb_uart_scoreboard::type_id::create("m_scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      m_apb_agent.monitor.item_collected_port.connect(m_scoreboard.apb_export);
      m_uart_tx_agent.monitor.item_collected_port.connect(m_scoreboard.uart_export);
    endfunction
  endclass : apb_uart_env

  // =========================================================================
  // 7. SEQUENCES & BASE TEST
  // =========================================================================

  // Base APB Sequence helper
  class apb_base_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(apb_base_seq)

    function new(string name = "apb_base_seq");
      super.new(name);
    endfunction

    task write_reg(bit [31:0] addr, bit [31:0] data);
      req = apb_seq_item::type_id::create("req");
      start_item(req);
      req.addr  = addr;
      req.write = 1'b1;
      req.wdata = data;
      finish_item(req);
    endtask

    task read_reg(bit [31:0] addr, output bit [31:0] data);
      req = apb_seq_item::type_id::create("req");
      start_item(req);
      req.addr  = addr;
      req.write = 1'b0;
      finish_item(req);
      data = req.rdata;
    endtask
  endclass : apb_base_seq

  // Base Test
  class apb_uart_base_test extends uvm_test;
    `uvm_component_utils(apb_uart_base_test)
    apb_uart_env m_env;

    function new(string name = "apb_uart_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_env = apb_uart_env::type_id::create("m_env", this);
    endfunction
  endclass : apb_uart_base_test

endpackage : apb_uart_pkg

`endif  // APB_UART_PKG_SV

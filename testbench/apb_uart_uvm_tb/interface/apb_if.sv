`ifndef __GUARD_APB_IF_SV__
`define __GUARD_APB_IF_SV__ 0

// APB interface: signals, modports and the tasks used by the driver and monitor
interface apb_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
) (
    input logic pclk,
    input logic presetn
);

  // --------------------------------------------------------------------------
  // APB signals
  // --------------------------------------------------------------------------
  logic                    psel;
  logic                    penable;
  logic [  ADDR_WIDTH-1:0] paddr;
  logic                    pwrite;
  logic [  DATA_WIDTH-1:0] pwdata;
  logic [DATA_WIDTH/8-1:0] pstrb;
  logic                    pready;
  logic [  DATA_WIDTH-1:0] prdata;
  logic                    pslverr;

  // --------------------------------------------------------------------------
  // Modports
  // --------------------------------------------------------------------------
  modport master  (output psel, penable, paddr, pwrite, pwdata, pstrb,
                   input  pready, prdata, pslverr);

  modport slave   (input  psel, penable, paddr, pwrite, pwdata, pstrb,
                   output pready, prdata, pslverr);

  modport monitor (input  psel, penable, paddr, pwrite, pwdata, pstrb,
                   input  pready, prdata, pslverr);

  // --------------------------------------------------------------------------
  // Reset: drive the master signals to their idle values.
  // pready, prdata and pslverr are driven by the DUT, never by this interface.
  // --------------------------------------------------------------------------
  task automatic apply_reset();
    psel    <= '0;
    penable <= '0;
    paddr   <= '0;
    pwrite  <= '0;
    pwdata  <= '0;
    pstrb   <= '0;
  endtask

  // --------------------------------------------------------------------------
  // Driver side: one APB transfer (setup phase, then access phase)
  // --------------------------------------------------------------------------
  task automatic do_transaction(
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic                  is_write,
    input  logic [DATA_WIDTH-1:0] wdata,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  slverr
  );
    // Setup phase: start on a clock edge
    @(posedge pclk);
    psel    <= 1'b1;
    penable <= 1'b0;
    paddr   <= addr;
    pwrite  <= is_write;
    pwdata  <= wdata;
    pstrb   <= is_write ? '1 : '0;

    // Access phase
    @(posedge pclk);
    penable <= 1'b1;

    // Wait until the slave is ready
    do @(posedge pclk); while (pready !== 1'b1);
    rdata  = prdata;
    slverr = pslverr;

    // End of transfer: go back to idle
    psel    <= 1'b0;
    penable <= 1'b0;
  endtask

  // --------------------------------------------------------------------------
  // Monitor side: wait for one complete APB transfer and report it
  // --------------------------------------------------------------------------
  task automatic get_transaction(
    output logic [ADDR_WIDTH-1:0] addr,
    output logic                  is_write,
    output logic [DATA_WIDTH-1:0] data,
    output logic                  slverr
  );
    // Wait for the setup phase
    do @(posedge pclk); while (!(presetn === 1'b1 && psel === 1'b1 && penable === 1'b0));
    // Wait for the end of the access phase
    do @(posedge pclk); while (!(presetn === 1'b1 && psel === 1'b1 && penable === 1'b1 && pready === 1'b1));

    addr     = paddr;
    is_write = pwrite;
    data     = pwrite ? pwdata : prdata;
    slverr   = pslverr;
  endtask

  // --------------------------------------------------------------------------
  // Simple helpers for directed access
  // --------------------------------------------------------------------------
  task automatic write(input logic [ADDR_WIDTH-1:0] addr, input logic [DATA_WIDTH-1:0] wdata);
    logic [DATA_WIDTH-1:0] unused_rdata;
    logic                  unused_slverr;
    do_transaction(addr, 1'b1, wdata, unused_rdata, unused_slverr);
  endtask

  task automatic read(input logic [ADDR_WIDTH-1:0] addr, output logic [DATA_WIDTH-1:0] rdata);
    logic unused_slverr;
    do_transaction(addr, 1'b0, '0, rdata, unused_slverr);
  endtask

  // --------------------------------------------------------------------------
  // Wait until psel has been low for x clock cycles in a row
  // --------------------------------------------------------------------------
  task automatic wait_till_idle(int x = 10);
    int idle_cycles = 0;
    while (idle_cycles < x) begin
      @(posedge pclk);
      idle_cycles++;
      if (psel === 1'b1) idle_cycles = 0;
    end
  endtask

endinterface

`endif

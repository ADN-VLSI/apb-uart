interface apb_if(input logic pclk, input logic presetn);
  logic psel;
  logic penable;
  logic pwrite;
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [3:0] pstrb;
  logic pready;
  logic [31:0] prdata;
  logic pslverr;

  task automatic write(input logic [31:0] address, input logic [31:0] data);
    @(negedge pclk);
    psel = 1'b1;
    penable = 1'b0;
    pwrite = 1'b1;
    paddr = address;
    pwdata = data;
    pstrb = '1;
    @(negedge pclk);
    penable = 1'b1;
    do @(posedge pclk); while (!pready);
    @(negedge pclk);
    psel = 1'b0;
    penable = 1'b0;
    pwrite = 1'b0;
    pwdata = '0;
    pstrb = '0;
  endtask

  task automatic read(input logic [31:0] address, output logic [31:0] data);
    @(negedge pclk);
    psel = 1'b1;
    penable = 1'b0;
    pwrite = 1'b0;
    paddr = address;
    pwdata = '0;
    pstrb = '0;
    @(negedge pclk);
    penable = 1'b1;
    do begin
      @(posedge pclk);
      if (pready) data = prdata;
    end while (!pready);
    @(negedge pclk);
    psel = 1'b0;
    penable = 1'b0;
  endtask
endinterface
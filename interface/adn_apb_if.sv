interface adn_apb_if(input logic pclk);
  logic presetn, psel, penable, pwrite;
  logic [31:0] paddr, pwdata, prdata;
  logic [3:0] pstrb;
  logic [2:0] pprot;
  logic pready, pslverr;

  clocking driver_cb @(posedge pclk);
    default input #1step output #1ns;
    output psel, penable, pwrite, paddr, pwdata, pstrb, pprot;
    input pready, prdata, pslverr;
  endclocking

  clocking monitor_cb @(posedge pclk);
    default input #1step;
    input presetn, psel, penable, pwrite, paddr, pwdata, pstrb, pprot;
    input pready, prdata, pslverr;
  endclocking
endinterface

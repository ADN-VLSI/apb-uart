`include "../include/adn_apb_uart_top_uvm_pkg.sv"

module apb_uart_top_uvm_tb;
	import uvm_pkg::*;
	import adn_apb_uart_top_uvm_pkg::apb_uart_write_test;
	logic pclk=0, irq, uart_tx; always #5ns pclk=~pclk;
	adn_apb_if apb(pclk); adn_uart_if uart();
	apb_req_t apb_req;
	apb_resp_t apb_resp;

	always_comb begin
		apb_req.psel    = apb.psel;
		apb_req.penable = apb.penable;
		apb_req.paddr   = apb.paddr;
		apb_req.pprot   = apb.pprot;
		apb_req.pwrite  = apb.pwrite;
		apb_req.pwdata  = apb.pwdata;
		apb_req.pstrb   = apb.pstrb;
	end
	assign apb.pready  = apb_resp.pready;
	assign apb.prdata  = apb_resp.prdata;
	assign apb.pslverr = apb_resp.pslverr;
	assign uart.line = uart.drive_enable ? uart.tx_driver : uart_tx;

	apb_uart_top dut(.PCLK(pclk),.PRESETn(apb.presetn),
		.apb_req_i(apb_req),
		.apb_resp_o(apb_resp),
		.UART_TX(uart_tx),.UART_RX(uart.line),.UART_IRQ(irq));

	initial begin
		string test_name;
		void'(apb_uart_write_test::type_id::get());
		apb.presetn=0; apb.psel=0; apb.penable=0; apb.pwrite=0; apb.paddr=0; apb.pwdata=0; apb.pstrb=0; apb.pprot=0;
		uart.drive_enable=0; uart.baud_rate=9600; uart.data_bits=8; uart.parity_en=0; uart.parity_type=0; uart.extra_stop=0;
		uvm_config_db#(virtual adn_apb_if)::set(null,"*","apb_vif",apb);
		uvm_config_db#(virtual adn_uart_if)::set(null,"*","uart_vif",uart);
		if (!$value$plusargs("TN=%s", test_name) || test_name == "default")
			test_name = "apb_uart_write_test";
		fork
			run_test(test_name);
			begin
				repeat(5) @(posedge pclk);
				apb.presetn=1;
			end
		join
	end
endmodule
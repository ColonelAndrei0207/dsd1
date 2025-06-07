/*
 AXI4_Lite interface used in the memory controller design
 It contains all of the signal used in the design (21 signals), with their respective bus size and name
 memory controller is considered a MASTER in this application
 it receives info from the UART driver and the memory
 */



interface axi_lite_interface(

		//global

		logic a_clk,
		logic a_reset_n,

		//write address channel

		logic aw_valid,
		logic aw_ready,
		logic [7:0] aw_addr,
		logic [2:0] aw_prot,

		//write data channel    -> same as for the write address channel

		logic w_valid,
		logic w_ready,
		logic [31:0] w_data,
		logic [3:0] w_strb,

		//write response channel

		logic b_valid,
		logic b_ready,
		logic [1:0] b_resp,

		//read address channel

		logic ar_valid,
		logic ar_ready,
		logic [7:0] ar_addr,
		logic [2:0] ar_prot,

		//READ data channel

		logic r_valid,
		logic r_ready,
		logic [31:0] r_data,
		logic [1:0] r_resp
	);
	
	
	//modport for master (memory controller)
	modport master (
		
		input aw_ready, w_ready, b_resp, ar_ready, r_data, r_resp, r_valid,
		output aw_addr, aw_valid, w_data, w_strb, w_valid, b_ready, ar_addr, ar_valid, r_ready,
		input a_clk, a_reset_n
		
		);
	
	
	modport slave (
		
		input aw_addr, aw_valid, w_data, w_strb, w_valid, b_ready, ar_addr, ar_valid, r_ready,
		output aw_ready, w_ready, b_resp, ar_ready, r_data, r_resp, r_valid,
		input a_clk, a_reset_n		
		
		);
	
	
	
	//modport for slave (UART driver)
	
endinterface





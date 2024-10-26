 `include "D:/FACULTATE/MASTER AM/semestrul 1/DSD1/sursa/tema1/golden_model.srcs/sources_1/new/defines.vh"


module etti_colonel_tb();

	logic   rst;
	logic   clk;
	logic [`A_BITS-1:0]  pc;
	logic  [15:0] instruction;
	logic   read;
	logic   write;
	logic  [`A_BITS-1:0] address;
	logic   [`D_BITS-1:0] data_in;
	logic  [`D_BITS-1:0] data_out;


	seq_core DUT(
		
		.rst(rst),
		.clk(clk),
		.pc(clk),
		.instruction(instruction),
		.read(read),
		.write(write),
		.address(address),
		.data_in(data_in),
		.data_out(data_out)
	);

endmodule
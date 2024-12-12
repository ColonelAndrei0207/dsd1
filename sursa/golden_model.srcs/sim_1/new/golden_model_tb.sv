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
		.pc(pc),
		.instruction(instruction),
		.read(read),
		.write(write),
		.address(address),
		.data_in(data_in),
		.data_out(data_out)
	);

initial begin

    clk = 0;

    forever begin
        #5 clk = ~clk;
    end
end

initial begin
    rst = 1;
    #10;
    rst = 0;
    #10;
    rst = 1;
    
    #10;
    
    instruction = {`LOADC, `R0, 8'd15};

    #40;

    instruction = {`LOADC, `R1, 8'd34};

    #40;

    instruction = {`ADD, `R0, `R0, `R1 };

    #40;

    instruction = {`STORE, `R1, `R0 };

    #40;

    $finish;

end


endmodule


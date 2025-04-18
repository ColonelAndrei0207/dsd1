/* execute stage file
 * it should contain the ALU (to be made) so that it can solve said instructions
 * ALU description is more or less a combination between the golden model and the ALU module description from 4th year ASC lab
 */
module stage_execute(

		//inputs from system
		input logic clk_i,
		input logic rst_i,

		//inputs from the READ_EXECUTE pipeline register

		input logic [`D_BITS-1:0] data_1_i,
		input logic [`D_BITS-1:0] data_2_i,
		input logic [6:0] opcode_i,
		input logic [2:0] dest_i,

		//output to the WRITE_BACK stage

		output logic [2:0] dest_o,
		output logic [`D_BITS-1:0] write_back_result_o,

		//TODO: ensure proper number of bits for the flag
		//output logic [`FLAGS_NR:0] flags_o, //flags_o output is used in order to deocde what the operation will actually do

		//outputs to the memory
		output logic write_o,
		output logic read_o,
		output  logic [`A_BITS-1:0]    address_o,
		output   logic  [`D_BITS-1:0]    data_out_o

	);

	logic [2:0] dest_s;

	logic [`A_BITS-1:0] address_w;
	logic [`A_BITS-1:0] address_s;

	logic [`FLAGS_NR-1:0] flags_w;
	logic [`D_BITS-1:0] result_s;

	logic [2:0] aux_s;

	logic [`D_BITS-1:0] data_out_s;
	
	logic [`D_BITS-1:0] write_back_result_s;


	alu ALU(
		.operand1_i(data_1_i),
		.operand2_i(data_2_i),
		.opcode_i(opcode_i),

		.aux_i(aux_s),

		.addr_o(address_w),

		.result_o(result_s),

		.flags_alu_o(flags_w)
	);


	assign data_out_s = ( flags_w == `WRITE_MEM ) ? result_s : 0;
	
	assign write_back_result_s = ((flags_w == `WRITE) || (flags_w == `READ) ) ? result_s : 0;
	
	assign address_s = ((flags_w == `WRITE_MEM) || (flags_w == `READ) ) ? address_w: 0;

	
	
	//a multiplexer that will redirect the dest_i either to the ALU or the WRITE_BACK stage
	always_comb begin

		if(opcode_i == `JMPC) begin

			aux_s = dest_i;

		end
		else begin

			dest_s = dest_i;

		end
	end


	//PIPELINE REGISTER between EXECUTE and WRITE BACK

//register used to transport dest_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			dest_o <= 0;

		end
		else begin

			dest_o <= dest_s;

		end
	end

//register used to transport dest_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			write_back_result_o <= 0;

		end
		else begin

			write_back_result_o <= write_back_result_s;

		end
	end


	//register outputs used for the connection between the processor and the data memory

//register used to transport address_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			address_o <= 0;

		end
		else begin

			address_o <= address_s;

		end
	end

//register used to transport data_out_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			data_out_o <= 0;

		end
		else begin

			data_out_o <= data_out_s;

		end
	end

	assign write_o = (flags_w == `WRITE_MEM) ? 1 : 0;
	assign read_o = (flags_w == `READ) ? 1 : 0;


endmodule



/* execute stage file
 *
 * Description of the EXECUTE stage
 *  It contains the ALU
 * It follows the description in the requirments and performs combinationally the instruction
 * Using combinational logic we output to the "data_memory" the required address, result and write/read flags, based on the results of the ALU
 * At the end, it contains the description of the pipeline register between the EXECUTE and WRITE BACK stages
 *
 */
 
module stage_execute(

		//inputs from system
		input logic clk_i,
		input logic rst_i,
		
		input logic stall_flag_i,

		//inputs from the READ_EXECUTE pipeline register

		input logic [`D_BITS-1:0] data_1_i,
		input logic [`D_BITS-1:0] data_2_i,
		input logic [6:0] opcode_i,
		input logic [2:0] dest_i,

		//output to the WRITE_BACK stage

		output logic [2:0] dest_o,
		output logic [`D_BITS-1:0] write_back_result_o,
		output logic [`D_BITS-1:0] alu_result_o,
		output logic [`FLAGS_NR-1:0] flags_o, //flags_o output is used in order to deocde what the operation will actually do

		//output to the FETCH stage (used when a JUMP instruction has been processed
		output logic [`A_BITS-1:0] execute_fetch_jump_value_o,

		//output directed for checking with the data_forwarding logic
		output logic [2:0] dest_alu_o,

		//outputs to the memory
		output logic write_o,
		output logic read_o,
		output  logic [`A_BITS-1:0]    address_o,
		output   logic  [`D_BITS-1:0]    data_out_o
		


	);

	logic [2:0] dest_s;

	logic [`A_BITS-1:0] address_w;

	logic [`FLAGS_NR-1:0] flags_s;
	logic [`D_BITS-1:0] result_s;

	logic [2:0] aux_s;

	logic [`D_BITS-1:0] write_back_result_s;

	logic [`A_BITS-1:0] execute_fetch_jump_value_s;


	ALU ALU_proccess(
		.operand1_i(data_1_i),
		.operand2_i(data_2_i),
		.opcode_i(opcode_i),

		.aux_i(aux_s),

		.addr_o(address_w),

		.result_o(result_s),

		.flags_alu_o(flags_s)
	);



	//intermediary variable used to transport from the ALU, the result of the operation to the Intermediary Pipeline Register between EXECUTE and WRITE_BACK stages
	assign write_back_result_s = ((flags_s == `WRITE) || (flags_s == `READ) ) ? result_s : 0;

	assign alu_result_o = write_back_result_s;

	assign execute_fetch_jump_value_s = ((flags_s == `JUMP_SIMPLE) || (flags_s == `JUMP_ADD) ) ? result_s[`A_BITS-1:0] : 0;

	//connections to the data_memory

	assign data_out_o = ( flags_s == `WRITE_MEM ) ? result_s : 0;
	assign address_o = ((flags_s == `WRITE_MEM) || (flags_s == `READ) ) ? address_w: 0;

	assign write_o = (flags_s == `WRITE_MEM) ? 1 : 0;
	assign read_o = (flags_s == `READ) ? 1 : 0;


	//a demultiplexer that will redirect the dest_i either to the ALU or the WRITE_BACK stage
	always_comb begin

		aux_s = 0;
		dest_s = 0;
		dest_alu_o = 0;

		if(opcode_i == `JMPC) begin

			aux_s = dest_i;

		end
		else begin

			dest_s = dest_i;
			dest_alu_o = dest_i;

		end
	end


	//PIPELINE REGISTER between EXECUTE and WRITE BACK

//register used to transport execute_fetch_jump_value_o

	always_ff @ (posedge clk_i, negedge rst_i) begin

		if(!rst_i) begin

			execute_fetch_jump_value_o <= 0 ;
		end
		else begin

			if ((flags_o == `STOP) || ( stall_flag_i )) begin

				execute_fetch_jump_value_o <= execute_fetch_jump_value_o;

			end
			else begin

				execute_fetch_jump_value_o <= execute_fetch_jump_value_s;

			end

		end



	end



//register used to transport dest_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			dest_o <= 0;

		end
		else begin
			if ((flags_o == `STOP) || ( stall_flag_i )) begin

				dest_o <= dest_o;

			end
			else begin

				dest_o <= dest_s;

			end
		end
	end

//register used to transport write_back_result_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			write_back_result_o <= 0;

		end
		else begin
			if ((flags_o == `STOP ) || ( stall_flag_i )) begin

				write_back_result_o <= write_back_result_o;

			end
			else begin

				write_back_result_o <= write_back_result_s;

			end
		end
	end

//register used to transport flags_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			flags_o <= 0;

		end
		else begin

			if (flags_o == `STOP ) begin

				flags_o <= flags_o;

			end

			else begin

				flags_o <= flags_s;

			end
		end
	end


endmodule





/* write_back stage file
 *
 * Simple description, decides which data should be outputed to the REGS file (either from previous stage or from data_in_i
 * No need for registers, fully combinational module
 *
 */
module stage_wrtie_back(

		//input from system
		input logic clk_i,
		input logic rst_i,

		//input from memory
		input logic [`D_BITS-1:0] data_in_i,

		//input from EXECTUE
		input logic [`D_BITS-1:0] execute_result_i,
		input logic [2:0] execute_dest_i,
		input logic [`FLAGS_NR-1 :0] flags_i,

		input logic stall_flag_i,


		//outputs to REGS
		output logic write_reg_o,
		output logic [2:0] dest_o,
		output logic [`D_BITS-1:0] result_o

	);

	//signals and data used for the LOAD and stall procedure
	logic [`D_BITS-1:0] tmp_data_in_s;
	logic exf_stall_flag;


	//assigning the outputs that do not require complex logic
	assign write_reg_o = ( (flags_i == `WRITE) || (flags_i == `READ)  ) ? 1 : 0;
	assign dest_o = ( (flags_i == `WRITE) || (flags_i == `READ)  ) ? execute_dest_i : 0;


	//register that memorizes the data_in_i value in case of stall and LOAD
	always_ff @ (posedge clk_i, negedge rst_i) begin
		
		if(!rst_i) begin

			tmp_data_in_s <= 0;

		end
		else begin
			if ((stall_flag_i) && ( flags_i == `READ ) ) begin

				tmp_data_in_s <= data_in_i;

			end
		end
	end

	assign exf_stall_flag = ( (flags_i == `READ) && (stall_flag_i) ) ? 1: 0;


	//a multiplexer that will direct the result_o either from the memory or the EXECUTE stage
	always_comb begin

		result_o = 0;

		if( flags_i == `WRITE ) begin

			result_o = execute_result_i;

		end
		else if ( flags_i == `READ ) begin
			if(stall_flag_i) begin

				result_o = execute_result_i; //data received from EXF when the LOAD is in the WRITE_BACK stage

			end
			else if (exf_stall_flag) begin //EXF result has been sent

				result_o = tmp_data_in_s; //send data from the LOAD

			end

			else begin  //normal operation of LOAD

				result_o = data_in_i;

			end

		end
		else begin

			result_o = 0;

		end
	end

endmodule




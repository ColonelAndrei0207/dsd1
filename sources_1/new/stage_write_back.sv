/* write_back stage file
 *
 *
 */
module stage_wrtie_back(

		//input from memory
		input logic [`D_BITS-1:0] data_in_i,

		//input from EXECTUE
		input logic [`D_BITS-1:0] data_execute_i,
		input logic [2:0] dest_execute_i,
		input logic [`FLAGS_NR :0 ] flags_i,
	

		//outputs to REGS
		output logic write_reg,
		output logic [2:0] dest_o,
		output logic [`D_BITS-1:0] result_o

	);
endmodule
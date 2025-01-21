/* fetch stage file
 *
 * Describes the reading of the instruction from the program memory
 * Describes the generation of the PC, both as a counter and with added values from the EXECUTE stage (when a jump instruction is executed)
 * Containts the pipeline register between FETCH and READ stages
 */

module stage_fetch(
		//inputs from system
		input   logic      rst_i,   // active 0
		input   logic      clk_i,


		input   logic   stall_flag_i,

		//output of the ProgramCounter
		output  logic [`A_BITS-1:0] pc_o,

		//used to receive the instruction
		input   logic        [15:0] instruction_i,

		//inputs from EXECUTE stage (used for jump instruction)
		input logic [`A_BITS-1:0] execute_fetch_jump_value_i,
		input logic [`FLAGS_NR-1:0] execute_fetch_flags_i,

		//output to the READ stage
		output logic [15:0] fetch_instruction_o

	);


	//TODO: add conditions + extra functionalities regarding updating the PC

	//implementation of the PC
	always_ff @(posedge clk_i, negedge rst_i) begin
		if(!rst_i)
			pc_o <= 0;
		else
		begin
			if(execute_fetch_flags_i == `JUMP_SIMPLE) begin //or any other condition that will reset/stop the counter

				pc_o <= execute_fetch_jump_value_i;

			end
			else if (execute_fetch_flags_i == `JUMP_ADD) begin

				pc_o <= pc_o + execute_fetch_jump_value_i;

			end
			else if ((execute_fetch_flags_i == `STOP) || (stall_flag_i) ) begin //flag used to signal that a HALT instruction has been processed

				pc_o <= pc_o;

			end
			else begin
				
				pc_o <= pc_o + 1;
			
			end
		end
	end


	//description of Instruction Register
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			fetch_instruction_o <= 0;

		end
		else begin

			if ( (execute_fetch_flags_i == `JUMP_SIMPLE) || (execute_fetch_flags_i == `JUMP_ADD) ) begin
				fetch_instruction_o <= 0;
			end
			else if ( (execute_fetch_flags_i == `STOP) || (stall_flag_i) ) begin

				fetch_instruction_o <= fetch_instruction_o;

			end
			else begin

				fetch_instruction_o <= instruction_i;
				
			end

		end

	end

endmodule




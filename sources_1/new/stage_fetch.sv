/* fetch stage file
 *
 *
 */

module stage_fetch(
		// used for the ProgramCounter
		input   logic      rst_i,   // active 0
		input   logic      clk_i,
		output  logic [`A_BITS-1:0] pc_o,

		//used to receive the instruction
		input   logic        [15:0] instruction_i,

		//
		output logic [15:0] fetch_instruction_o

	);


	//TODO: add conditions + extra functionalities regarding updating the PC
	//implementation of the PC
	always_ff @(posedge clk_i, negedge rst_i) begin
		if(!rst_i)
			pc_o <= 0;
		else //if(halt) //or any other condition that will reset/stop the counter
			//pc <= pc;
		//else
			pc_o <= pc_o + 1;

	end

		//description of Instruction Register
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin
			fetch_instruction_o <= 0;
		end
		else begin
			fetch_instruction_o <= instruction_i;
		end

	end

endmodule
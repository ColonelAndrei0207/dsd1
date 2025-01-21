/* REGS file
 * simple module that contains all the registers used in the processor
 * Can be expanded by modifying the macros in the defines.vh file
 * It also inputs and outputs flags that ensure proper read
 * When it writes data from the WRITE BACK stage, it acts like a normal register
 *
 */
module regs(

		//inputs from system
		input logic clk_i,
		input logic rst_i,

		//inputs from READ stage
		input logic [2:0] src_1_i,
		input logic [2:0] src_2_i,

		//output to READ stage
		output logic [`D_BITS-1:0] operand_1_o,
		output logic [`D_BITS-1:0] operand_2_o,

		//inputs from WRITE_BACK stage
		input logic wen_i,
		input logic [2:0] dest_i,
		input logic [`D_BITS-1:0] result_i

	);

	reg [ `D_BITS-1:0 ] gen_reg[0:`REG_NR-1]; //declaration of the register array

	//the process of reading from the register set when it's contents are accessed by the READ stage
	always_comb begin

		operand_1_o = gen_reg[src_1_i];
		operand_2_o = gen_reg[src_2_i];

	end

	//the process of writing to the register set when it's contents are accessed by the WRITE BACK stage
	always_ff @ (posedge clk_i, negedge rst_i) begin

		if(!rst_i) begin

			for (int i = 0; i<`REG_NR; i++) begin
				gen_reg[i] <= 0;
			end

		end
		else begin
			if(wen_i) begin

				gen_reg[dest_i] <= result_i;

			end
			else begin
			//action is commented due to unimportant redundancy that should save power
			//gen_reg[dest_i] <= gen_reg[dest_i];

			end

		end
	end

endmodule



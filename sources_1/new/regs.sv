/* REGS file
 * more or less the description received on the 4th year @ ASC lab
 *
 */
module regs(

		//inputs from system
		input logic clk_i,
		input logic rst_i,

		//inputs from READ stage
		input logic [2:0] src_1_i,
		input logic [2:0] src_2_i,
		input logic regs_start_i,

		//output to READ stage
		output logic [`D_BITS-1:0] operand_1_o,
		output logic [`D_BITS-1:0] operand_2_o,

		//inputs from WRITE_BACK stage
		input logic wen_i,
		input logic [2:0] dest_i,
		input logic [`D_BITS-1:0] result_i

	);

	reg [ `D_BITS-1:0 ] gen_reg[0:`REG_NR-1];

	always_comb begin

		operand_1_o = 0;
		operand_2_o = 0;

		if(regs_start_i) begin
			operand_1_o = gen_reg[src_1_i];
			operand_2_o = gen_reg[src_2_i];
		end
		else begin
			operand_1_o = 0;
			operand_2_o = 0;
		end
	end


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
			
			gen_reg[dest_i] <= 0;
			
			end
			
		end
	end

endmodule




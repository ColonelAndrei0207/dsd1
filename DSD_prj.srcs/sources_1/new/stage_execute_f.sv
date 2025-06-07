/*  FILE DESCRIPTION:f _execute stage file
 *
 * As described in the document, it will contain 4 pipeline registers, connected using internal wires
 * For each register (stage of the pipeline) a step of the algorithm will be implemented.
 *      2 options:
 *          a) in each always_ff block I process said step
 *          b) each always_ff block that describes the register is in pair with an always_comb block that processes said step
 * Main 4 steps are:
 *  1. comparison
 *
 *      Compares the 2 data inputted
 *
 *  2. alignment
 *
 *  Ensures that the data are alligned in order to do the actual addition / substraction
 *
 *  3. addition
 *
 *      Actual instruction calculation
 *
 *
 *  4. renormalization
 *
 *      Ensures that the result outputted follows the IEEE 1800-2012 standard regarding floating point data
 *
 *
 *  In the end, the pipeline register between the EXECUTE_F stage and WRITE_BACK stage is implemented
 *
 */
module stage_execute_f(

		//inputs from system
		input logic clk_i,
		input logic rst_i,

		//input from the EXECUTION block (the flags) in order to clear or hold in case of jump or HALT
		input logic [`FLAGS_NR-1:0] flags_i,

		//inputs from the READ_EXECUTE pipeline register

		input logic [`D_BITS-1:0] data_1_i,
		input logic [`D_BITS-1:0] data_2_i,
		input logic [6:0] opcode_i,
		input logic [2:0] dest_i,

		//output from r4 to the data_forwarding block
		output logic [2:0] dest_r4_o,
		output logic [`D_BITS-1:0] write_back_result_s4_o,

		//output to the WRITE_BACK stage

		output logic [2:0] dest_o,
		output logic [`D_BITS-1:0] write_back_result_o

	);



	logic [7:0] exp_tmp;
	logic [7:0] exp_tmp_s4;
	// Extract mantissas with implicit leading bit
	logic [23:0] mant_a; //one extra bit for allignment purpose 
	logic [23:0] mant_b; //one extra bit for allignment purpose
	logic [24:0] mant_result;  // One extra bit for carry/borrow

	logic [24:0] mant_tmp_s4;

	logic sign_result;


	//intermediary outputs between the 4 internal registers

	//outputs of r1
	logic [`D_BITS-1:0] data_1_s1;
	logic [`D_BITS-1:0] data_2_s1;
	logic [1:0] comparison_s; //result of the comparison; if comparison_s == 1, it means that R1 has the larger exponent, if comparison_s == 2 R2 has the larger exponent, else they are equal
	logic [2:0] dest_s1;


	//outputs of r2
	logic [`D_BITS-1:0] data_1_s2;
	logic [`D_BITS-1:0] data_2_s2;
	logic [2:0] dest_s2;

	//outputs of r3
	logic [2:0] dest_s3;
	logic [`D_BITS-1:0] write_back_result_s3;

	//outputs of r4
	logic [2:0] dest_s4;
	logic [`D_BITS-1:0] write_back_result_s4;



	//PIPELINE REGISTERS used to implement the action of EXF, as described in the assignment

//r1    ->comparison
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			data_1_s1 <= 0;
			data_2_s1 <= 0;
			comparison_s <= 0;
			dest_s1 <= 0;

		end
		else begin
			dest_s1 <= dest_i;
			
			if ( data_1_i[`F_E_FLOP] > data_2_i[`F_E_FLOP] ) begin

				comparison_s <= 1;
				data_1_s1 <= data_1_i;
				data_2_s1 <= data_2_i;
			end
			else if ( data_1_i[`F_E_FLOP] < data_2_i[`F_E_FLOP] ) begin

				comparison_s <= 2;
				data_1_s1 <= data_1_i;
				data_2_s1 <= data_2_i;

			end

			else begin

				comparison_s <= 0;
				data_1_s1 <= data_1_i;
				data_2_s1 <= data_2_i;

			end
		end
	end


//r2    ->alignment
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			data_1_s2 <= 0;
			data_2_s2 <= 0;
			sign_result <= 0;
			mant_a <=0;
			mant_b <=0;
			exp_tmp<=0;
			dest_s2 <= 0; 


		end
		else begin
			dest_s2 <= dest_s1;
			
			if ( comparison_s == 0 ) begin

				data_1_s2 <= data_1_s1;
				data_2_s2 <= data_2_s1;

			end
			else if (comparison_s == 1) begin //if R1 has a larger exponent, we need to align R2

				data_1_s2 <= data_1_s1;
				data_2_s2 <= { data_2_s1[`D_BITS-1], data_2_s1[`F_E_FLOP] ,data_2_s1[`F_M_FLOP] >> (data_1_s1[`F_E_FLOP] - data_2_s1[`F_E_FLOP] ) };

			end
			else if (comparison_s == 2) begin //if R2 has a larger exponent, we need to align R1

				data_1_s2 <= { data_1_s1[`D_BITS-1], data_1_s1[`F_E_FLOP], data_1_s1[`F_M_FLOP] >> (data_2_s1[`F_E_FLOP] - data_1_s1[`F_E_FLOP] ) };
				data_2_s2 <= data_2_s1;

			end
			else begin

				data_1_s2 <= data_1_s1;
				data_2_s2 <= data_2_s1;

			end
			sign_result <= data_1_s2[31];
			mant_a <= {1'b1, data_1_s1[`F_M_FLOP]};
			mant_b <= {1'b1, data_2_s1[`F_M_FLOP]};

			if(comparison_s == 1) begin
				exp_tmp <= data_1_s2[`F_E_FLOP];
			end
			else begin
				exp_tmp <= data_2_s2[`F_E_FLOP];
			end
		end

	end

//r3    -> addition
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if (!rst_i) begin
			write_back_result_s3 <= 0;
			dest_s3 <= 0;
			mant_result <=0;


		end
		else begin
			dest_s3 <= dest_s2;

			// Determine the exponent for the result

			if (data_1_s2[31] == data_2_s2[31]) begin  // Same signs

				if (opcode_i == `ADDF) begin
					mant_result <= mant_a + mant_b;
				end else if (opcode_i == `SUBF) begin
					mant_result <= mant_a - mant_b;
				end
			end else begin  // Different signs
				if (opcode_i == `ADDF) begin
					mant_result <= mant_a - mant_b;
				end else if (opcode_i == `SUBF) begin
					mant_result <= mant_a + mant_b;
				end
			end



			write_back_result_s3 <= {sign_result, exp_tmp, mant_result[22:0]};  // Discard extra bit
		end
	end



//r4    -> renormalization
	always_ff @(posedge clk_i or negedge rst_i) begin
		if (!rst_i) begin
			write_back_result_s4 <= 0;
			dest_s4 <= 0;
			mant_tmp_s4 <= 0;
			exp_tmp_s4 <= 0;
		end else begin
			dest_s4 <= dest_s3;

			mant_tmp_s4 <= mant_result; //we need to have the extra one for the calculation and the extra zero in case of the carry
			exp_tmp_s4 <= write_back_result_s3[`F_E_FLOP];

			if(mant_tmp_s4[23]) begin //handle overflow

				mant_tmp_s4 <= mant_tmp_s4 >>1;
				exp_tmp_s4 <= exp_tmp_s4 +1;

			end

			else begin
				if (mant_tmp_s4[23] == 0 && exp_tmp_s4 != 0) begin
					if (mant_tmp_s4[22]) begin
						mant_tmp_s4 <= mant_tmp_s4 << 1;
						exp_tmp_s4 <= exp_tmp_s4 - 1;
					end
					if (mant_tmp_s4[21]) begin
						mant_tmp_s4 <= mant_tmp_s4 << 2;
						exp_tmp_s4 <= exp_tmp_s4 - 2;
					end
					if (mant_tmp_s4[19]) begin
						mant_tmp_s4 <= mant_tmp_s4 << 4;
						exp_tmp_s4 <= exp_tmp_s4 - 4;
					end
					if (mant_tmp_s4[15]) begin
						mant_tmp_s4 <= mant_tmp_s4 << 8;
						exp_tmp_s4 <= exp_tmp_s4 - 8;
					end
					if (mant_tmp_s4[7]) begin
						mant_tmp_s4 <= mant_tmp_s4 << 16;
						exp_tmp_s4 <= exp_tmp_s4 - 16;
					end
				end
			end

			write_back_result_s4 <= { sign_result, exp_tmp_s4, mant_tmp_s4[22:0] };
		end
	end


	assign dest_r4_o = dest_s4; //assignation used to connect the output to the data_forwarding block with the final register of the floating_point operation 
	assign write_back_result_s4_o = write_back_result_s4;

	//PIPELINE REGISTER between EXECUTE and WRITE BACK

//register used to transport dest_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			dest_o <= 0;

		end
		else begin
			if ( (flags_i == `JUMP_ADD) || ( flags_i == `JUMP_SIMPLE ) ) begin

				dest_o <= 0;

			end

			else if (  flags_i == `STOP  ) begin

				dest_o <= dest_o;

			end

			else begin

				dest_o <= dest_s4;

			end

		end
	end

//register used to transport write_back_result_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			write_back_result_o <= 0;

		end
		else begin
			if ( (flags_i == `JUMP_ADD) || ( flags_i == `JUMP_SIMPLE ) ) begin

				write_back_result_o <= 0;

			end
			else if  ( flags_i == `STOP )  begin

				write_back_result_o <= write_back_result_o;

			end
			else begin

				write_back_result_o <= write_back_result_s4;

			end

		end
	end


endmodule




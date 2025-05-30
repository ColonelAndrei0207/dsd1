/* ALU file
 * description of the ALU module that is placed inside the exectue stage
 * ALU description is more or less a combination between the golden model and the ALU module description from 4th year ASC lab
 */

//TODO: eventually use "alias" or assign operations for operand2_i when doing JMP operations (in order to ease the reading and debugging of code)
 `include "D:/FACULTATE/MASTER AM/semestrul 1/DSD1/sursa/tema1/golden_model.srcs/sources_1/new/defines.vh"

module alu(
		//inputs from the READ stage
		input logic [`D_BITS-1:0] operand1_i,
		input logic [`D_BITS-1:0] operand2_i,
		input logic [6:0] opcode_i,
		input logic [2:0] aux_i,

		//outputs to the memory
		output logic [`A_BITS-1:0] addr_o,
		
		//outputs to the WRITE_BACK stage
		output logic [`D_BITS-1:0] result_o,

		output logic [`FLAGS_NR-1:0] flags_alu_o

	);

	always_comb begin

		result_o = 0;
		flags_alu_o = 0;

		casex(opcode_i)

			`JMP:
			begin

				result_o = operand1_i; //pc = R[op0]
				flags_alu_o = `JUMP;

			end
			`JMPR: begin

				result_o[`F_JMP_OFF] = operand1_i[`F_JMP_OFF];
				flags_alu_o = `JUMP;

			end

			`JMPC:
			begin

				case(aux_i) //check condition
					`N:
					begin
						if (operand2_i < 0) begin

							result_o = operand1_i; //pc = R[op1]
							flags_alu_o = `JUMP;

						end
					end

					`NN:
					begin
						if (operand2_i >= 0) begin

							result_o = operand1_i; //pc = R[op1]
							flags_alu_o = `JUMP;

						end
					end

					`Z:
					begin
						if (operand2_i == 0) begin

							result_o = operand1_i; //pc = R[op1]
							flags_alu_o = `JUMP;

						end
					end

					`NZ:
					begin
						if (operand2_i != 0) begin

							result_o = operand1_i; //pc = R[op1]
							flags_alu_o = `JUMP;

						end
					end
					default: flags_alu_o = `BLANK;

				endcase

			end

			`JMPRC:
			begin

				case(operand2_i[8:6]) //check condition
					`N:
					begin
						if (operand1_i < 0) begin
							result_o[`F_JMP_OFF] =  operand2_i[`F_JMP_OFF];
							flags_alu_o = `JUMP;
						end
					end

					`NN:
					begin
						if (operand1_i >= 0) begin
							result_o[`F_JMP_OFF] =  operand2_i[`F_JMP_OFF];
							flags_alu_o = `JUMP;
						end
					end

					`Z:
					begin
						if (operand1_i == 0) begin
							result_o[`F_JMP_OFF] =  operand2_i[`F_JMP_OFF];
							flags_alu_o = `JUMP;
						end
					end

					`NZ:
					begin
						if (operand1_i != 0) begin
							result_o[`F_JMP_OFF] =  operand2_i[`F_JMP_OFF];
							flags_alu_o = `JUMP;
						end
					end

					default: flags_alu_o = `BLANK;
				endcase

			end


			`LOAD:
			begin
				result_o = operand1_i;
				addr_o = operand2_i[ `A_BITS-1:0 ];
				flags_alu_o = `READ;

			end//endload

			`STORE:
			begin

				result_o = operand1_i;
				addr_o = operand2_i[ `A_BITS-1:0];
				flags_alu_o = `WRITE;

			end

			`LOADC:

			begin

				result_o = operand1_i << `CST_NR_BITS;
				result_o[`F_LS_CST] = operand2_i[`F_LS_CST];
				flags_alu_o = `WRITE;

			end




			`NOP: flags_alu_o = `BLANK;
			`HALT: flags_alu_o = `STOP;

			`ADD:
			begin

				result_o = operand1_i + operand2_i;
				flags_alu_o = `WRITE;

			end

			`ADDF:
			begin   //currently no need for floating point

				result_o = operand1_i + operand2_i;
				flags_alu_o = `WRITE;

			end


			`SUB:
			begin

				result_o = operand1_i - operand2_i;
				flags_alu_o = `WRITE;

			end

			`SUBF:
			begin   //currently no need for floating point

				result_o = operand1_i - operand2_i;
				flags_alu_o = `WRITE;


			end


			`AND:
			begin


				result_o = operand1_i & operand2_i;
				flags_alu_o = `WRITE;

			end

			`OR:
			begin

				result_o = operand1_i | operand2_i;
				flags_alu_o = `WRITE;

			end

			`XOR:
			begin

				result_o = operand1_i ^ operand2_i;
				flags_alu_o = `WRITE;

			end


			`NAND:
			begin

				result_o = ~( operand1_i & operand2_i );
				flags_alu_o = `WRITE;

			end

			`NOR:
			begin

				result_o = ~(operand1_i | operand2_i );
				flags_alu_o = `WRITE;

			end

			`NXOR:
			begin

				result_o = ~(operand1_i ^ operand2_i );
				flags_alu_o = `WRITE;

			end


			`SHIFTR:
			begin

				result_o = operand1_i >> operand2_i[5:0];
				flags_alu_o = `WRITE;

			end

			`SHIFTRA:
			begin
				result_o = operand1_i >>> operand2_i[5:0];
				flags_alu_o = `WRITE;

			end

			`SHIFTL:
			begin

				result_o = operand1_i << operand2_i[5:0];
				flags_alu_o = `WRITE;
			end

			default: flags_alu_o = `BLANK;
		endcase
	end



endmodule


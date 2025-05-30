/* read stage file
 * READ stage will decipher the opcode, prepare, eventually from REGS, the operands that will be used for the execution of the instruction, and will send them to the EXECUTE stage
 *      always_comb for generating the intermediary outputs, then use a always_ff for sending tho the intermediary register
 */
module stage_read(

		//i/o ports to and from REGS

		input logic regs_stop_i,
		output logic regs_start_o,

		// i/o ports from system

		input   logic      rst_i,   // active 0
		input   logic      clk_i,

		// i/o ports for operand 1
		output  logic [2:0]    src_1_o,
		input   logic  [`D_BITS-1:0]    operand_1_i,

		// i/o ports for operand 2
		output  logic [2:0]    src_2_o,
		input   logic  [`D_BITS-1:0]    operand_2_i,

		//input from InstructionRegister (assimilated into the stage_fetch module
		input  logic [15:0]    read_instruction_i,

		//output to ExecuteRegister
		output logic [`D_BITS-1:0]    data_1_o,
		output logic [`D_BITS-1:0]    data_2_o,
		output logic [2:0] dest_o, //dest_o can either be sent DIRECTLY to the WRITE_BACK stage, or can be used inside the EXECUTE, as part of an ALU input
		output logic [6:0] opcode_o

	);

	//intermediary variables declaration for connecting the combinational logic with the pipeline Register
	logic [6:0] opcode_s;
	logic [2:0] dest_s;
	logic [`D_BITS-1:0] data_2_s;
	logic [`D_BITS-1:0] data_1_s;

	//assignation of the intermediary opcode_s variable with it's corresponding place in read_instruction_i
	assign opcode_s = read_instruction_i[15:9]; 

	//always_comb block that deals with the src outputs and dest_s
	always_comb begin

		src_1_o = 0;
		src_2_o = 0;
		dest_s = 0;
		regs_start_o = 0; //signal used in order to give the REGS block the proper sources for the data

		casex(read_instruction_i[15:9] )
			`ADD, `ADDF, `SUB, `SUBF, `AND, `NAND, `OR, `NOR, `XOR, `NXOR:
			begin
				src_1_o = read_instruction_i[`F_AL_OP1];
				src_2_o = read_instruction_i[`F_AL_OP2];
				dest_s  = read_instruction_i[`F_AL_OP0];
				regs_start_o = 1;
			end

			`SHIFTL, `SHIFTR, `SHIFTRA:
			begin

				src_1_o = read_instruction_i[`F_SH_OP0];
				regs_start_o = 1;

			end

			`LOAD, `STORE:
			begin
				src_1_o = read_instruction_i[`F_LS_OP0];
				src_2_o = read_instruction_i[`F_LS_OP1];
				regs_start_o = 1;


			end

			`LOADC:
			begin

				src_1_o = read_instruction_i[`F_LS_OP0];
				regs_start_o = 1;

			end

			`JMP:
			begin
				src_1_o = read_instruction_i[`F_JMP_OP];
				regs_start_o = 1;

			end

			`JMPC:
			begin
				dest_s = read_instruction_i[`F_JMP_CND];
				src_1_o = read_instruction_i[`F_JMP_OP0];
				src_2_o = read_instruction_i[`F_JMP_OP1];
				regs_start_o = 1;
			end


			`JMPR:
			begin

			end

			`JMPRC:
			begin

				src_1_o = read_instruction_i[`F_JMP_OP0];
				regs_start_o = 1;

			end


			default: begin

				src_1_o =0;
				src_2_o =0;
				regs_start_o = 0;
				dest_s = 0;
			end

		endcase

	end

	//always_comb block that deals with the data_s outputs
	always_comb begin

		data_1_s = 0;
		data_2_s = 0;

		if (regs_stop_i) begin //condition placed in order to ensure that the proper data has been received

			casex(read_instruction_i[15:9] )
				`ADD, `ADDF, `SUB, `SUBF, `AND, `NAND, `OR, `NOR, `XOR, `NXOR:
				begin

					data_1_s = operand_1_i;
					data_2_s = operand_2_i;

				end

				`SHIFTL, `SHIFTR, `SHIFTRA:
				begin

					data_1_s = operand_1_i;
					data_2_s[5:0] = read_instruction_i[5:0];

				end

				`LOAD, `STORE:
				begin
					data_1_s = operand_1_i;
					data_2_s = operand_2_i;

				end

				`LOADC:
				begin

					data_1_s = operand_1_i;
					data_2_s[`F_LS_CST] = read_instruction_i[`F_LS_CST];

				end

				`JMP:
				begin

					data_1_s = operand_1_i;

				end

				`JMPC:
				begin

					data_1_s = operand_1_i;
					data_2_s = operand_2_i;


				end


				`JMPR:
				begin

					data_2_s[`F_JMP_OFF] = read_instruction_i[`F_JMP_OFF];

				end

				`JMPRC:
				begin

					data_1_s = operand_1_i;
					data_2_s[`F_JMP_OFF] = read_instruction_i[`F_JMP_OFF];  //the offset
					data_2_s[8:6] = read_instruction_i [`F_JMP_CND];    //the condition

				end


				default: begin

					data_1_s = 0;
					data_2_s = 0;

				end

			endcase

		end
		else begin

			data_1_s = 0;
			data_2_s = 0;

		end

	end


	//PIPELINE REGISTER between READ stage and EXECUTE stage

	//register used to transport opcode_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			opcode_o <= 0;

		end
		else begin

			opcode_o <= opcode_s;

		end
	end

//register used to transport dest_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			dest_o <= 0;

		end
		else begin

			dest_o <= dest_s;

		end
	end

//register used to transport data_1_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			data_1_o <= 0;

		end
		else begin

			data_1_o <= data_1_s;

		end
	end

//register used to transport data_2_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			data_2_o <= 0;

		end
		else begin

			data_2_o <= data_2_s;

		end
	end


endmodule




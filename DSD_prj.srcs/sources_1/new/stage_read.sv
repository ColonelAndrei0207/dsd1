/* read stage file

 Contains 2 combinational processes
 1. Describes, based on the opcode received from the instruction, how to handle the sources and the destination of the instrcution
 2. Receives from the REGS module the data that will be sent to the next STAGE
 Contains the pipeline register between the READ and EXECUTE(_F) stages
 */
module stage_read(

		input logic [`D_BITS-1:0] data_forward_i,
		input logic  [1:0] flag_forward_i,

		//input from the EXECUTE stage, used to update opcode in case of jump

		input logic [`FLAGS_NR-1:0] execute_fetch_flags_i,
		
		input logic stall_flag_i,

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

		casex(read_instruction_i[15:9] )
			`ADD, `ADDF, `SUB, `SUBF, `AND, `NAND, `OR, `NOR, `XOR, `NXOR:
			begin
				src_1_o = read_instruction_i[`F_AL_OP1];
				src_2_o = read_instruction_i[`F_AL_OP2];
				dest_s  = read_instruction_i[`F_AL_OP0];

			end

			`SHIFTL, `SHIFTR, `SHIFTRA:
			begin

				src_1_o = read_instruction_i[`F_SH_OP0];
				dest_s = read_instruction_i[`F_SH_OP0];

			end

			`LOAD: //for load we want to get the 2 registers from the REGS set
			begin

				src_2_o = read_instruction_i[`F_LS_OP1];
				dest_s = read_instruction_i[`F_LS_OP0];


			end

			`STORE: //for store we want to get the 2 registers from the REGS set
			begin

				src_1_o = read_instruction_i[`F_LS_OP0]; //R[op1] is the register that is being sent to the memory
				src_2_o = read_instruction_i[`F_LS_OP1]; //R[op0] has it's address taken (it is nedeed fully)


			end

			`LOADC: //for LOADC we want to take a register from the REGS set, and load it's LS 8 bits with the constant found in the instruction body
			begin

				src_1_o = read_instruction_i[`F_LS_OP0];
				dest_s = read_instruction_i[`F_LS_OP0];

			end

			`JMP:
			begin
				src_1_o = read_instruction_i[`F_JMP_OP];

			end

			`JMPC:
			begin
				dest_s = read_instruction_i[`F_JMP_CND];
				src_1_o = read_instruction_i[`F_JMP_OP0];
				src_2_o = read_instruction_i[`F_JMP_OP1];
			end


			`JMPR:
			begin

			end

			`JMPRC:
			begin

				src_1_o = read_instruction_i[`F_JMP_OP0];

			end


			default: begin

				src_1_o =0;
				src_2_o =0;
				dest_s = 0;
			end

		endcase

	end

	//always_comb block that deals with the data_s outputs
	always_comb begin

		data_1_s = 0;
		data_2_s = 0;

		casex(read_instruction_i[15:9] )
			`ADD, `ADDF, `SUB, `SUBF, `AND, `NAND, `OR, `NOR, `XOR, `NXOR:
			begin
				if( flag_forward_i == 1 ) begin

					data_1_s = data_forward_i;
					data_2_s = operand_2_i;

				end
				else if (  flag_forward_i == 2 ) begin

					data_1_s = operand_1_i;
					data_2_s = data_forward_i;

				end
				else begin

					data_1_s = operand_1_i;
					data_2_s = operand_2_i;

				end


			end

			`SHIFTL, `SHIFTR, `SHIFTRA:
			begin
				if (flag_forward_i == 1) begin

					data_1_s = data_forward_i;

				end
				else begin

					data_1_s = operand_1_i;

				end

				data_2_s[5:0] = read_instruction_i[5:0];

			end

			`LOAD:
			begin

				if( flag_forward_i == 1 ) begin

					data_1_s = data_forward_i;
					data_2_s = operand_2_i;

				end
				else if (  flag_forward_i == 2 ) begin

					data_1_s = operand_1_i;
					data_2_s = data_forward_i;

				end
				else begin

					data_1_s = operand_1_i;
					data_2_s = operand_2_i;

				end


			end

			`STORE:
			begin

				if( flag_forward_i == 1 ) begin

					data_1_s = data_forward_i;
					data_2_s = operand_2_i;

				end
				else if (  flag_forward_i == 2 ) begin

					data_1_s = operand_1_i;
					data_2_s = data_forward_i;

				end
				else begin

					data_1_s = operand_1_i;
					data_2_s = operand_2_i;

				end

			end


			`LOADC:
			begin

				if (flag_forward_i == 1) begin

					data_1_s = data_forward_i;

				end
				else begin

					data_1_s = operand_1_i;

				end


				data_2_s[`F_LS_CST] = read_instruction_i[`F_LS_CST];

			end

			`JMP:
			begin

				if (flag_forward_i == 1) begin

					data_1_s = data_forward_i;

				end
				else begin

					data_1_s = operand_1_i;

				end

			end

			`JMPC:
			begin

				if( flag_forward_i == 1 ) begin

					data_1_s = data_forward_i;
					data_2_s = operand_2_i;

				end
				else if (  flag_forward_i == 2 ) begin

					data_1_s = operand_1_i;
					data_2_s = data_forward_i;

				end
				else begin

					data_1_s = operand_1_i;
					data_2_s = operand_2_i;

				end


			end


			`JMPR:
			begin

				data_1_s[`F_JMP_OFF] = read_instruction_i[`F_JMP_OFF];

			end

			`JMPRC:
			begin

				if (flag_forward_i == 1) begin

					data_1_s = data_forward_i;

				end
				else begin

					data_1_s = operand_1_i;

				end
				data_2_s[`F_JMP_OFF] = read_instruction_i[`F_JMP_OFF];  //the offset
				data_2_s[8:6] = read_instruction_i [`F_JMP_CND];    //the condition

			end


			default: begin

				data_1_s = 0;
				data_2_s = 0;

			end

		endcase

	end


//PIPELINE REGISTER between READ stage and EXECUTE stage
//TODO: check how JUMP instructions are processed

//register used to transport opcode_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			opcode_o <= 0;

		end
		else begin
			if ( (execute_fetch_flags_i == `JUMP_SIMPLE) || (execute_fetch_flags_i == `JUMP_ADD) ) begin
				opcode_o <= 0;
			end
			else if ((execute_fetch_flags_i == `STOP) || ( stall_flag_i ) ) begin

				opcode_o <= opcode_o;

			end
			else begin

				opcode_o <= opcode_s;

			end

		end
	end

//register used to transport dest_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			dest_o <= 0;

		end
		else begin

			if ( (execute_fetch_flags_i == `JUMP_SIMPLE) || (execute_fetch_flags_i == `JUMP_ADD) ) begin
				dest_o <= 0;
			end
			else if ( (execute_fetch_flags_i == `STOP) || ( stall_flag_i ) ) begin

				dest_o <= dest_o;

			end
			else begin

				dest_o <= dest_s;
			end

		end
	end

//register used to transport data_1_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			data_1_o <= 0;

		end
		else begin

			if ( (execute_fetch_flags_i == `JUMP_SIMPLE) || (execute_fetch_flags_i == `JUMP_ADD) ) begin
				data_1_o <= 0;
			end
			else if ((execute_fetch_flags_i == `STOP) || ( stall_flag_i ) ) begin

				data_1_o <= data_1_o;

			end
			else begin

				data_1_o <= data_1_s;
			end

		end
	end

//register used to transport data_2_o
	always_ff @ (posedge clk_i, negedge rst_i) begin
		if(!rst_i) begin

			data_2_o <= 0;

		end
		else begin

			if ( (execute_fetch_flags_i == `JUMP_SIMPLE) || (execute_fetch_flags_i == `JUMP_ADD) ) begin
				data_2_o <= 0;
			end
			else if (( execute_fetch_flags_i == `STOP) || ( stall_flag_i ) ) begin

				data_2_o <= data_2_o;

			end
			else begin

				data_2_o <= data_2_s;
			end

		end
	end


endmodule



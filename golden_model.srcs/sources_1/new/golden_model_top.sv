/**************************
  * (C) Copyright 2024 All Rights Reserved
  *
  * MODULE: spi_training_counter
  * DEVICE: spi_training_counter
  * PROJECT: SPI SLAVE digital design training
  * AUTHOR: Colonel Andrei
  * DATE:
  * FILE:
  * REVISION:
  *
  * FILE DESCRIPTION: Simple counter that generates a variable that counts the number of sclk pulses, while also sending the pulses_nr_error output
  *
  ***************************/

 `include "D:/FACULTATE/MASTER AM/semestrul 1/DSD1/sursa/tema1/golden_model.srcs/sources_1/new/defines.vh"



 //TODO: De modificat la fiecare instructiune in parte, folosind solutia propusa de mihai la instructiunea ADD

module seq_core(
		// general
		input   logic      rst,   // active 0
		input   logic      clk,
		// program memory
		output  logic [`A_BITS-1:0] pc,
		input   logic        [15:0] instruction,
		// data memory
		output  logic      read,  // active 1
		output  logic      write, // active 1
		output  logic [`A_BITS-1:0]    address,
		input   logic  [`D_BITS-1:0]    data_in,
		output  logic [`D_BITS-1:0]    data_out
	);

//register delcaration

	reg [`D_BITS - 1 : 0] gen_reg[0:7] ;
	reg [`D_BITS - 1 : 0] reg1;
	reg [`D_BITS - 1 : 0] reg2;
	reg [`D_BITS - 1 : 0] reg3;
	reg [`D_BITS - 1 : 0] reg4;
	reg [`D_BITS - 1 : 0] reg5;
	reg [`D_BITS - 1 : 0] reg6;
	reg [`D_BITS - 1 : 0] reg7;



	logic [6:0] opcode7 = 0; //used in order to select the intruction type basen on the number of bits needed inside the instruction
	logic [4:0] opcode5 = 0;
	logic [3:0] opcode4 = 0;

	logic [2:0] op_value0 = 0; //used in order to select register based of opx value (where opx can be op0, op1 or op2) //final value can be reg0, reg1,...
	logic [2:0] op_value1 = 0;
	logic [2:0] op_value2 = 0;

	task instruction_decode ( logic [15:0] instruction_code );

		logic [6:0] t_opcode = 0; //temporary opcode that will be filled

		opcode7 = 0;
		opcode4 = 0;
		opcode5 = 0;

		t_opcode = instruction_code[15:9]; //we set into the temporary variable the presumed operation code

		if ((t_opcode == 0) && (t_opcode == 128) ) //if we have NOP or HALT
			opcode7 = t_opcode;
		else if ( (t_opcode > 0 ) && ( t_opcode < 5 ) ) //if we have JMP and derivatives instructions
			opcode4 = t_opcode[15:12];
		else if (( t_opcode > 6 ) && ( t_opcode < 8) ) //if we have LOAD(C)/STORE instructions
			opcode5 = t_opcode[15:11];
		else if (( t_opcode > 9 ) && ( t_opcode < 21 ) ) //if we have logical and arithmetical instructions
			opcode7 = t_opcode;
		else if ( (t_opcode > 22) && (t_opcode < 127) )
			//error
			$display("%0t weird situation we have here",$time() );

	endtask

	task operand_choice( logic [2:0] operand, bit n);

		reg [`D_BITS - 1 : 0] reg_out;

		if (n == 0) begin

			case (operand)

				`R0:
				begin
					reg_out <= reg0;
				end

				`R1:
				begin
					reg_out <= reg1;
				end

				`R2:
				begin
					reg_out <= reg2;
				end

				`R3:
				begin
					reg_out <= reg3;
				end

				`R4:
				begin
					reg_out <= reg4;
				end

				`R5:
				begin
					reg_out <= reg5;
				end

				`R6:
				begin
					reg_out <= reg6;
				end

				`R7:
				begin
					reg_out <= reg7;
				end

				default: pc <= pc;

			endcase
		end

		else begin
			case (operand)

				`R0:
				begin
					reg0 <= reg_out;
				end

				`R1:
				begin
					reg1 <= reg_out;
				end

				`R2:
				begin
					reg2 <= reg_out;
				end

				`R3:
				begin
					reg3 <= reg_out;
				end

				`R4:
				begin
					reg4 <= reg_out;
				end

				`R5:
				begin
					reg5 <= reg_out;
				end

				`R6:
				begin
					reg6 <= reg_out;
				end

				`R7:
				begin
					reg7 <= reg_out;
				end

				default: pc <= pc;

			endcase
		end

	endtask

	//main process block
	always_ff @(posedge clk, negedge rst) begin

		if (rst == 0) begin
			reg0 <=0;
			reg1 <=0;
			reg2 <=0;
			reg3 <=0;
			reg4 <=0;
			reg5 <=0;
			reg6 <=0;
			reg7 <=0;
			pc <=0;
			read <=0;
			write <=0;
			data_out <=0;
			address <=0;

		end
		else begin

			instruction_decode(instruction); //now I have either opcode4, opcode5 or opcode7 (every instruction type implemented
			if (opcode4 !=0) begin
				case(opcode4)
					`JMP:   pc[2:0] <= instruction[2:0]; //pc = op0
					`JMPR:  pc <= pc + instruction[5:0];
					`JMPC:
					begin
						case(instruction[11:9]) //check condition
							`N:
							begin
								if (instruction[8:6] < 0) //
									pc[2:0] <= instruction[2:0];
							end

							`NN:
							begin
								if (instruction[8:6] >= 0)
									pc[2:0] <= instruction[2:0];
							end

							`Z:
							begin
								if (instruction[8:6] == 0)
									pc[2:0] <= instruction[2:0];
							end

							`NZ:
							begin
								if (instruction[8:6] != 0)
									pc[2:0] <= instruction[2:0];
							end
						endcase
					end

					`JMPRC:
					begin
						case(instruction[11:9]) //check condition
							`N:
							begin
								if (instruction[8:6] < 0)
									pc <= pc + instruction[5:0];
							end

							`NN:
							begin
								if (instruction[8:6] >= 0)
									pc <= pc + instruction[5:0];
							end

							`Z:
							begin
								if (instruction[8:6] == 0)
									pc <= pc + instruction[5:0];
							end

							`NZ:
							begin
								if (instruction[8:6] != 0)
									pc <= pc + instruction[5:0];
							end
						endcase
					end

					default: pc <= pc;
				endcase //endcase for opcode4
			end //condition in place in order to skip the case statement

			if (opcode5 !=0) begin
				case(opcode5)

					/*we are loading into an internal register; we need address -> "Only the last A_BITS of R[op1] are used as memory address"
					 * reg0[2:0] aka op1 will get us the actual register (R1, R2...)
					 * now that we have the register; we send it as per the description (write into data_out)

					 */
					`LOAD:
					begin
						case (instruction[2:0])
							`R0:
							begin
								reg0 <= data_in;
								address <= reg0[ `D_BITS - 1 : `D_BITS - `A_BITS];
								pc <= pc + 1;
							end

							`R1:
							begin
								reg1 <= data_in;
								address <= reg1[ `D_BITS - 1 : `D_BITS - `A_BITS];
								pc <= pc + 1;
							end

							`R2:
							begin
								reg2 <= data_in;
								address <= reg2[ `D_BITS - 1 : `D_BITS - `A_BITS];
								pc <= pc + 1;
							end

							`R3:
							begin
								reg3 <= data_in;
								address <= reg3[ `D_BITS - 1 : `D_BITS - `A_BITS];
								pc <= pc + 1;
							end

							`R4:
							begin
								reg4 <= data_in;
								address <= reg4[ `D_BITS - 1 : `D_BITS - `A_BITS];
								pc <= pc + 1;
							end

							`R5:
							begin
								reg5 <= data_in;
								address <= reg5[ `D_BITS - 1 : `D_BITS - `A_BITS];
								pc <= pc + 1;
							end

							`R6:
							begin
								reg6 <= data_in;
								address <= reg6[ `D_BITS - 1 : `D_BITS - `A_BITS];
								pc <= pc + 1;
							end

							`R7:
							begin
								reg7 <= data_in;
								address <= reg7[ `D_BITS - 1 : `D_BITS - `A_BITS];
								pc <= pc + 1;
							end

							default: pc <= pc;
						endcase
					end//endload


					`LOADC:
					/*
					 * into a register set by op0, we will load the constant;
					 * first we will shift to the left with 8 bits so that we can load said constant to the LSBs
					 */
					begin
						case (instruction[10:8])
							`R0:
							begin
								reg0 <= reg0 << 8;
								reg0[7:0] <= instruction[7:0];
								pc <= pc + 1;

							end

							`R1:
							begin
								reg1 <= reg1 << 8;
								reg1[7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R2:
							begin
								reg2 <= reg2 << 8;
								reg2[7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R3:
							begin
								reg3 <= reg3 << 8;
								reg3[7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R4:
							begin
								reg4 <= reg4 << 8;
								reg4[7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R5:
							begin
								reg5 <= reg5 << 8;
								reg5[7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R6:
							begin
								reg6 <= reg6 << 8;
								reg6[7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R7:
							begin
								reg7 <= reg7 << 8;
								reg7[7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							default: pc <= pc;

						endcase

					end

					`STORE:
					/* with op0 we will get the address, with op1 we will get both the said register and data_out
					 *TODO: register find through task (need both register for op0 and for op1
					 */
					begin

					end

				endcase

			end
			if (opcode7 != 0) begin
				case(opcode7)

					`NOP: pc <= pc + 1;
					`HALT: pc <= 0 ;

					`ADD:
					begin
						logic [`D_BITS - 1 : 0] reg_out0 = 0;
						logic [`D_BITS - 1 : 0] reg_out1 = 0;
						logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						//reg_out0 = reg_out1 + reg_out2;
						gen_reg[instruction[8:6] ] = gen_reg[instruction[5:3] ] + gen_reg[instruction[2:0] ];
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end

					`ADDF:
					begin

						logic [`D_BITS - 1 : 0] reg_out0 = 0;
						logic [`D_BITS - 1 : 0] reg_out1 = 0;
						logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 + reg_out2;
						//reg1 = reg2 + reg3
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end


					`SUB:
					begin
						logic [`D_BITS - 1 : 0] reg_out0 = 0;
						logic [`D_BITS - 1 : 0] reg_out1 = 0;
						logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 - reg_out2;
						//reg1 = reg2 + reg3
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place
					end

					`SUBF:
					begin

						logic [`D_BITS - 1 : 0] reg_out0 = 0;
						logic [`D_BITS - 1 : 0] reg_out1 = 0;
						logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 - reg_out2;
						//reg1 = reg2 + reg3
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end


					`AND:
					begin

						logic [`D_BITS - 1 : 0] reg_out0 = 0;
						logic [`D_BITS - 1 : 0] reg_out1 = 0;
						logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 & reg_out2;
						//reg1 = reg2 + reg3
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end

					`OR:
					begin

						logic [`D_BITS - 1 : 0] reg_out0 = 0;
						logic [`D_BITS - 1 : 0] reg_out1 = 0;
						logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 | reg_out2;
						//reg1 = reg2 + reg3
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end

					`XOR:
					begin

						logic [`D_BITS - 1 : 0] reg_out0 = 0;
						logic [`D_BITS - 1 : 0] reg_out1 = 0;
						logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 ^ reg_out2;
						//reg1 = reg2 + reg3
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end


					`NAND:
					begin

						logic [`D_BITS - 1 : 0] reg_out0 = 0;
						logic [`D_BITS - 1 : 0] reg_out1 = 0;
						logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = ~(reg_out1 & reg_out2);
						//reg1 = reg2 + reg3
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end

					`NOR:
					begin

						logic [`D_BITS - 1 : 0] reg_out0 = 0;
						logic [`D_BITS - 1 : 0] reg_out1 = 0;
						logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = ~(reg_out1 | reg_out2);
						//reg1 = reg2 + reg3
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end

					`NXOR:
					begin

						logic [`D_BITS - 1 : 0] reg_out0 = 0;
						logic [`D_BITS - 1 : 0] reg_out1 = 0;
						logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = ~(reg_out1 ^ reg_out2);
						//reg1 = reg2 + reg3
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end


					`SHIFTR:
					begin

					end

					`SHIFTRA:
					begin

					end

					`SHIFTL:
					begin

					end



				endcase


			end


		end


	end

endmodule
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

	reg [`D_BITS - 1 : 0] gen_reg [0:7] ;

	logic [6:0] opcode7 = 0; //used in order to select the intruction type basen on the number of bits needed inside the instruction
	logic [4:0] opcode5 = 0;
	logic [3:0] opcode4 = 0;

	logic [2:0] op_value0 = 0; //used in order to select register based of opx value (where opx can be op0, op1 or op2) //final value can be reg0, reg1,...
	logic [2:0] op_value1 = 0;
	logic [2:0] op_value2 = 0;

	function instruction_decode (input logic [15:0] instruction_code );

		static logic  [6:0] t_opcode = 0; //temporary opcode that will be filled

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

	endfunction

	function operand_choice( input logic [2:0] operand, input bit n);

		reg [`D_BITS - 1 : 0] reg_out;

		if (n == 0) begin

			case (operand)

				`R0:
				begin
					reg_out <= gen_reg[0];
				end

				`R1:
				begin
					reg_out <= gen_reg[1];
				end

				`R2:
				begin
					reg_out <= gen_reg[2];
				end

				`R3:
				begin
					reg_out <= gen_reg[3];
				end

				`R4:
				begin
					reg_out <= gen_reg[4];
				end

				`R5:
				begin
					reg_out <= gen_reg[5];
				end

				`R6:
				begin
					reg_out <= gen_reg[6];
				end

				`R7:
				begin
					reg_out <= gen_reg[7];
				end

				default: reg_out <= reg_out;

			endcase
		end

		else begin
			case (operand)

				`R0:
				begin
					gen_reg[0] <= reg_out;
				end

				`R1:
				begin
					gen_reg[1] <= reg_out;
				end

				`R2:
				begin
					gen_reg[2] <= reg_out;
				end

				`R3:
				begin
					gen_reg[3] <= reg_out;
				end

				`R4:
				begin
					gen_reg[4] <= reg_out;
				end

				`R5:
				begin
					gen_reg[5] <= reg_out;
				end

				`R6:
				begin
					gen_reg[6] <= reg_out;
				end

				`R7:
				begin
					gen_reg[7] <= reg_out;
				end

				default: reg_out <= reg_out;

			endcase
		end

	endfunction

	//main process block
	always_ff @(posedge clk, negedge rst) begin

		if (rst == 0) begin
			gen_reg[0] <=0;
			gen_reg[1] <=0;
			gen_reg[2] <=0;
			gen_reg[3] <=0;
			gen_reg[4] <=0;
			gen_reg[5] <=0;
			gen_reg[6] <=0;
			gen_reg[7] <=0;
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


    //TODO: modify the LOAD instruction in order to actually get the right address, as well as load the proper register
			if (opcode5 !=0) begin
				case(opcode5)

					/*we are loading into an internal register; we need address -> "Only the last A_BITS of R[op1] are used as memory address"
					 * reg0[2:0] aka op1 will get us the actual register (R1, R2...)
					 * now that we have the register; we send it as per the description (write into data_out)

					 */
					`LOAD:
					begin
					  static logic [`D_BITS - 1 : 0] reg_out0 = 0;
					  static logic [`D_BITS - 1 : 0] reg_out1 = 0;
					  
					  reg_out0 = operand_choice(instruction[10:8], 0 ).reg_out;
					  reg_out1 = operand_choice(instruction[2:0], 0 ).reg_out;
					  
					  reg_out0 <= data_in;
					  address <= reg_out1[ `D_BITS - 1 : `D_BITS - `A_BITS];
					  pc <= pc + 1;
					  					  					  
					  operand_choice(instruction [10:8], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place    

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
								gen_reg[0] <= gen_reg[0] << 8;
								gen_reg[0][7:0] <= instruction[7:0];
								pc <= pc + 1;

							end

							`R1:
							begin
								gen_reg[1] <= gen_reg[1] << 8;
								gen_reg[1][7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R2:
							begin
								gen_reg[2] <= gen_reg[2] << 8;
								gen_reg[2][7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R3:
							begin
								gen_reg[3] <= gen_reg[3] << 8;
								gen_reg[3][7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R4:
							begin
								gen_reg[4] <= gen_reg[4] << 8;
								gen_reg[4][7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R5:
							begin
								gen_reg[5] <= gen_reg[5] << 8;
								gen_reg[5][7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R6:
							begin
								gen_reg[6] <= gen_reg[6] << 8;
								gen_reg[6][7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							`R7:
							begin
								gen_reg[7] <= gen_reg[7] << 8;
								gen_reg[7][7:0] <= instruction[7:0];
								pc <= pc + 1;
							end

							default: pc <= pc;

						endcase

					end

					`STORE:
					/* with op0 we will get the address, with op1 we will get both the said register and data_out
					 *TODO: register find through task (need both register for op0 and for op1
					 */
					     //TODO: modify the STORE instruction in order to actually get the right address, as well as load the proper register
					begin
					
					  static logic [`D_BITS - 1 : 0] reg_out0 = 0;
					  static logic [`D_BITS - 1 : 0] reg_out1 = 0;
					  
					  reg_out0 = operand_choice(instruction[10:8], 0 ).reg_out;
					  reg_out1 = operand_choice(instruction[2:0], 0 ).reg_out;
					  
					  data_out <= reg_out1;
					  address <= reg_out0[ `D_BITS - 1 : `D_BITS - `A_BITS];
					  pc <= pc + 1;					  					  

					end

				endcase

			end
			if (opcode7 != 0) begin
				case(opcode7)

					`NOP: pc <= pc + 1;
					`HALT: pc <= 0 ;

					`ADD:
					begin
						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						static logic [`D_BITS - 1 : 0] reg_out1 = 0;
						static logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 + reg_out2;
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end

					`ADDF:
					begin

						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						static logic [`D_BITS - 1 : 0] reg_out1 = 0;
						static logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 + reg_out2;
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end


					`SUB:
					begin
						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						static logic [`D_BITS - 1 : 0] reg_out1 = 0;
						static logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 - reg_out2;
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place
					end

					`SUBF:
					begin

						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						static logic [`D_BITS - 1 : 0] reg_out1 = 0;
						static logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 - reg_out2;
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end


					`AND:
					begin

						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						static logic [`D_BITS - 1 : 0] reg_out1 = 0;
						static logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 & reg_out2;
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end

					`OR:
					begin

						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						static logic [`D_BITS - 1 : 0] reg_out1 = 0;
						static logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 | reg_out2;
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end

					`XOR:
					begin

						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						static logic [`D_BITS - 1 : 0] reg_out1 = 0;
						static logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = reg_out1 ^ reg_out2;
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end


					`NAND:
					begin

						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						static logic [`D_BITS - 1 : 0] reg_out1 = 0;
						static logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = ~(reg_out1 & reg_out2);
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end

					`NOR:
					begin

						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						static logic [`D_BITS - 1 : 0] reg_out1 = 0;
						static logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = ~(reg_out1 | reg_out2);
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end

					`NXOR:
					begin

						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						static logic [`D_BITS - 1 : 0] reg_out1 = 0;
						static logic [`D_BITS - 1 : 0] reg_out2 = 0;

						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						reg_out1 = operand_choice(instruction[5:3], 0 ).reg_out;
						reg_out2 = operand_choice(instruction[2:0], 0 ).reg_out;

						reg_out0 = ~(reg_out1 ^ reg_out2);
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place

					end


					`SHIFTR:
					begin
						static logic [`D_BITS - 1 : 0] reg_out0 = 0;


						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;

						reg_out0 = reg_out0 >> instruction[5:0];
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place
					end

					`SHIFTRA:
					begin
						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						static logic msb;
						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;
						
						msb = reg_out0[31]; //save the sign bit inside the "msb" variable
						reg_out0[31] = 0; 

						reg_out0 = reg_out0 >> instruction[5:0]; //perform the shifting as normal
						pc <= pc+1;
						reg_out0[31] = msb; //overwrite the sign bit, back to it's original value

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place
					end

					`SHIFTL:
					begin
						static logic [`D_BITS - 1 : 0] reg_out0 = 0;
						reg_out0 = operand_choice(instruction[8:6], 0 ).reg_out;

						reg_out0 = reg_out0 << instruction[5:0];
						pc <= pc+1;

						operand_choice(instruction [8:6], 1).reg_out = reg_out0; //here we reput the value of register of op0 back to its place
					end
				endcase
			end
		end
	end
endmodule
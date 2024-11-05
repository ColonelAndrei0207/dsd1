 /*  GOLDEN MODEL file
  *  Used for the DSD1 project
  *
  */

 `include "/home/digdevel/training/nodm/default/units/etti_colonel/source/rtl/defines.svh"


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

	task instruction_decode (input logic [15:0] instruction_code );

		static logic  [6:0] t_opcode = 0; //temporary opcode that will be filled

		opcode7 = 0;
		opcode4 = 0;
		opcode5 = 0;

		t_opcode = instruction_code[15:9]; //we set into the temporary variable the presumed operation code

		if ((t_opcode == 0) && (t_opcode == 7'b1111111) ) //if we have NOP or HALT
			opcode7 = t_opcode;
		else if ( (t_opcode >= 7'b0000001 ) && ( t_opcode <= 7'b0001101 ) ) //if we have logical and arithmetical instructions
			opcode7 = t_opcode;
		else if (( t_opcode >= 7'b1000100 ) && ( t_opcode <= 7'b1001100) ) //if we have LOAD(C)/STORE instructions
			opcode5 = t_opcode[6:2];
		else if (( t_opcode >= 7'b1011000 ) && ( t_opcode <= 7'b1110000 ) ) //if we have logical and arithmetical instructions
			opcode4 = t_opcode[6:3];
		else 
			//error
			$display("%0t weird situation we have here",$time() );

	endtask

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

			instruction_decode(instruction); //now I have either opcode4, opcode5 or opcode7 (every instruction type implemented)

			if (opcode4 !=0) begin
				
				case(opcode4)
					`JMP:   pc[2:0] <= instruction[2:0]; //pc = op0
					`JMPR:  pc <= pc + instruction[5:0];
					
					`JMPC:
					begin
						case(instruction[11:9]) //check condition
							`N:
							begin
								if (instruction[8:6] < 0) 
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


			else if (opcode5 !=0) begin
				case(opcode5)

					`LOAD:
					begin
						gen_reg[instruction[10:8]] <= data_in;
						address <= gen_reg[ instruction[2:0] ] [ `D_BITS - 1 : `D_BITS - `A_BITS];
						pc <= pc + 1;
						read <=1;

					end//endload

					`LOADC:

					begin

						gen_reg[instruction[10:8]] <= gen_reg[ instruction[10:8] ] << 8;
						gen_reg[instruction[10:8]][7:0] <= instruction[7:0];
						pc <= pc + 1;

					end

					`STORE:
					begin

						data_out <= gen_reg[ instruction[2:0] ];
						address <= gen_reg[ instruction[10:8] ][ `D_BITS - 1 : `D_BITS - `A_BITS];
						pc <= pc + 1;
						write <= 1;

					end

				endcase

			end
			else if (opcode7 != 0) begin
				case(opcode7)

					`NOP: pc <= pc + 1;
					`HALT: pc <= 0 ;

					`ADD:
					begin

						gen_reg [ instruction[8:6] ] <= gen_reg [ instruction[5:3] ] + gen_reg [ instruction[2:0] ];
						pc <= pc+1;

					end

					`ADDF:
					begin	//currently no need for floating point

						gen_reg [ instruction[8:6] ] <= gen_reg [ instruction[5:3] ] + gen_reg [ instruction[2:0] ];
						pc <= pc+1;

					end


					`SUB:
					begin

						gen_reg [ instruction[8:6] ] <= gen_reg [ instruction[5:3] ] - gen_reg [ instruction[2:0] ];
						pc <= pc+1;
					end

					`SUBF:
					begin	//currently no need for floating point

						gen_reg [ instruction[8:6] ] <= gen_reg [ instruction[5:3] ] - gen_reg [ instruction[2:0] ];
						pc <= pc+1;

					end


					`AND:
					begin


						gen_reg [ instruction[8:6] ] <= gen_reg [ instruction[5:3] ] & gen_reg [ instruction[2:0] ];
						pc <= pc+1;

					end

					`OR:
					begin

						gen_reg [ instruction[8:6] ] <= gen_reg [ instruction[5:3] ] | gen_reg [ instruction[2:0] ];
						pc <= pc+1;

					end

					`XOR:
					begin

						gen_reg [ instruction[8:6] ] <= gen_reg [ instruction[5:3] ] ^ gen_reg [ instruction[2:0] ];
						pc <= pc+1;

					end


					`NAND:
					begin

						gen_reg [ instruction[8:6] ] <= ~(gen_reg [ instruction[5:3] ] & gen_reg [ instruction[2:0] ] );
						pc <= pc+1;

					end

					`NOR:
					begin

						gen_reg [ instruction[8:6] ] <= ~(gen_reg [ instruction[5:3] ] | gen_reg [ instruction[2:0] ] );
						pc <= pc+1;

					end

					`NXOR:
					begin

						gen_reg [ instruction[8:6] ] <= ~(gen_reg [ instruction[5:3] ] ^ gen_reg [ instruction[2:0] ] );
						pc <= pc+1;

					end


					`SHIFTR:
					begin

						gen_reg[ instruction[8:6] ] <= gen_reg[ instruction[8:6] ] >> instruction[5:0];
						pc <= pc+1;

					end

					`SHIFTRA:
					begin
						gen_reg[ instruction[8:6] ] <= gen_reg[ instruction[8:6] ] >>> instruction[5:0];
						pc <= pc+1;

					end

					`SHIFTL:
					begin

						gen_reg[ instruction[8:6] ] <= gen_reg[ instruction[8:6] ] << instruction[5:0];
						pc <= pc+1;
					end
				endcase
			end
			
			else begin				
					//no decoded opcode				
			end			
		end
	end
endmodule

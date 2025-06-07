 `timescale 1ns/10ps

 /* main processor architecture file
  * it includes the 4 level pipeline structure: FETCH, READ, EXECUTE, WRITE BACK
  * "TOP" design file
  *
  * Besides the separate modules written for each stage of the pipeline processor, it also contains combinational logic used for:
  *     1. Decoding of the data-type used in the instruction (either integer or floating-poin)
  *     2. Directional block that decides, based on the decoder described at 1. where to send the data and instruction (either to the integer-based block or the FP-based block)
  *     3. Directional block that decides which data enters the WRITE_BACK stage (it will also incorporate backpressure elements)
  *     4. Data-forwarding decision block, used if data dependecies are detected
  *     5. Stalling-decision block that will complement the data-forwarding decision block
  *
  * Pipeline stage files are described in their respective module, which also contain the pipeline register used "AFTER" the stage
  *     For example, the FETCH module also contains the pipeline register between the FETCH and READ stages
  *
  */

module procesor(

		// general
		input   logic      rst_i,   // active 0
		input   logic      clk_i,
		// program memory
		output  logic [`A_BITS-1:0] pc_o,
		input   logic        [15:0] instruction_i,
		// data memory
		output  logic      read_o,  // active 1
		output  logic      write_o, // active 1
		output  logic [`A_BITS-1:0]    address_o,
		input   logic  [`D_BITS-1:0]    data_in_i,
		output  logic [`D_BITS-1:0]    data_out_o

	);

	//wires used to connect the stages modules between themselves



	//wire used to transport flags to the rest of the stages(important when JUMP instructions are executed)
	logic [`FLAGS_NR-1:0] processor_flags_w;
	logic stall_flag_w;

	//connections between fetch and read
	logic [15:0] fetch_read_instruction_w;

	//connections between fetch and execute
	logic [`A_BITS-1:0] execute_fetch_jump_value_w;
	//  logic [`FLAGS_NR-1:0] execute_write_back_flags_w;


	//connections between regs and read
	logic [2:0] regs_src_1_w;
	logic [`D_BITS-1:0] regs_operand_1_w;

	logic [2:0] regs_src_2_w;
	logic [`D_BITS-1:0] regs_operand_2_w;


	//outputs of the READ stage that go into the combinational block for redirecting to the proper execute path
	logic [2:0] read_dest_w;
	logic [`D_BITS-1:0] read_data_1_w;
	logic [`D_BITS-1:0] read_data_2_w;
	logic [6:0] read_opcode_w;


	//connections between read and execute
	logic [2:0] read_execute_dest_w;
	logic [`D_BITS-1:0] read_execute_data_1_w;
	logic [`D_BITS-1:0] read_execute_data_2_w;
	logic [6:0] read_execute_opcode_w;

	//connections between read and execute_f
	logic [2:0] read_execute_f_dest_w;
	logic [`D_BITS-1:0] read_execute_f_data_1_w;
	logic [`D_BITS-1:0] read_execute_f_data_2_w;
	logic [6:0] read_execute_f_opcode_w;


	//connections between execute and write_back
	logic [`D_BITS-1:0] execute_write_back_result_w;
	logic [2:0] execute_write_back_dest_w;


	//connections between execute(_f) and the data forwarding block
	logic [2:0] dest_alu_w;
	logic [2:0] dest_r4_w;

	logic [`D_BITS-1:0] alu_result_w;
	logic [`D_BITS-1:0] write_back_result_s4_w;


	//connections between execute_f and write_back
	logic [2:0] execute_f_write_back_dest_w;
	logic [`D_BITS-1:0] execute_f_write_back_result_w;

	//connections between the output of the decision_taking block between the execute(_f) and write back stage(s)
	logic [2:0] write_back_dest_w;
	logic [`D_BITS-1:0] write_back_result_w;


	//connections between write_back and regs
	logic [`D_BITS-1:0] write_back_regs_result_w;
	logic [2:0] write_back_regs_dest_w;
	logic write_back_regs_wen_w;


	//variables used to generate and connect the stalling flag between the stalling logic and the stages
	logic stall_s;


	//variable used to connect the flags for data_forwarding to the READ stage
	logic [1:0] flag_forward_w;
	logic [`D_BITS-1:0] data_forward_w;

	//intermediary wire used for the multiplexers that connect the READ stage with the EXECUTE or F_EXECUTE stages and for the connection between the WRITE_BACK stage and the execution stages
	logic opcode_diferent_w;



	stage_read read(

		.execute_fetch_flags_i(processor_flags_w),
		.flag_forward_i(flag_forward_w),
		.data_forward_i(data_forward_w),

		.stall_flag_i(stall_flag_w),


		.clk_i(clk_i),
		.rst_i(rst_i),

		.src_1_o(regs_src_1_w),
		.operand_1_i(regs_operand_1_w),


		.src_2_o(regs_src_2_w),
		.operand_2_i(regs_operand_2_w),

		.read_instruction_i(fetch_read_instruction_w),

		.dest_o(read_dest_w),
		.data_1_o(read_data_1_w),
		.data_2_o(read_data_2_w),
		.opcode_o(read_opcode_w)
	);


	stage_fetch fetch(
		// used for the ProgramCounter
		.rst_i(rst_i),   // active 0
		.clk_i(clk_i),

		.stall_flag_i(stall_flag_w),

		.pc_o(pc_o),

		.execute_fetch_jump_value_i(execute_fetch_jump_value_w),
		.execute_fetch_flags_i(processor_flags_w),

		.instruction_i(instruction_i),

		.fetch_instruction_o(fetch_read_instruction_w)
	);


	//decoder for the opcode. If the operation is floting-point-based, it outputs 1, else it outputs 0
	always_comb begin

		opcode_diferent_w = 0;
		if ( ( read_opcode_w == `ADDF) || ( read_opcode_w == `SUBF ) ) begin
			opcode_diferent_w = 1;
		end
		else begin
			opcode_diferent_w = 0;
		end
	end


	regs REGS(
		.clk_i(clk_i),
		.rst_i(rst_i),

		.src_1_i(regs_src_1_w),
		.operand_1_o(regs_operand_1_w),

		.src_2_i(regs_src_2_w),
		.operand_2_o(regs_operand_2_w),

		.wen_i(write_back_regs_wen_w),
		.dest_i(write_back_regs_dest_w),
		.result_i(write_back_regs_result_w)

	);

	//combinational block that directs the output of the READ stage to the proper execution branch (either EXECUTE or F_EXECUTE)
	//TODO: when implementing data-control and JUMP behavior, add additional conditions based on the proper flags
	always_comb begin

		read_execute_dest_w = 0;
		read_execute_data_1_w = 0;
		read_execute_data_2_w = 0;
		read_execute_opcode_w = 0;

		read_execute_f_dest_w = 0;
		read_execute_f_data_1_w = 0;
		read_execute_f_data_2_w = 0;
		read_execute_f_opcode_w = 0;

		if(!stall_flag_w) begin

			if (opcode_diferent_w) begin //sends data to EXECUTE_F

				read_execute_f_dest_w = read_dest_w;
				read_execute_f_data_1_w = read_data_1_w;
				read_execute_f_data_2_w = read_data_2_w;
				read_execute_f_opcode_w = read_opcode_w;

			end
			else begin  //else it send data to EXECUTE

				read_execute_dest_w = read_dest_w;
				read_execute_data_1_w = read_data_1_w;
				read_execute_data_2_w = read_data_2_w;
				read_execute_opcode_w = read_opcode_w;

			end
		end
		else begin

			read_execute_dest_w = 0;
			read_execute_data_1_w = 0;
			read_execute_data_2_w = 0;
			read_execute_opcode_w = 0;

			read_execute_f_dest_w = 0;
			read_execute_f_data_1_w = 0;
			read_execute_f_data_2_w = 0;
			read_execute_f_opcode_w = 0;

		end

	end



	stage_execute execute(

		.rst_i(rst_i),
		.clk_i(clk_i),

		.stall_flag_i(stall_flag_w),

		.data_1_i(read_execute_data_1_w),
		.data_2_i(read_execute_data_2_w),
		.opcode_i(read_execute_opcode_w),
		.dest_i(read_execute_dest_w),

		.dest_o(execute_write_back_dest_w),
		.write_back_result_o(execute_write_back_result_w),
		.flags_o(processor_flags_w),

		.dest_alu_o(dest_alu_w),
		.alu_result_o(alu_result_w),

		.execute_fetch_jump_value_o(execute_fetch_jump_value_w),

		.address_o(address_o),
		.data_out_o(data_out_o),
		.write_o(write_o),
		.read_o(read_o)

	);


	stage_execute_f execute_f(

		.clk_i(clk_i),
		.rst_i(rst_i),

		.flags_i(processor_flags_w),
		.data_1_i(read_execute_f_data_1_w),
		.data_2_i(read_execute_f_data_2_w),
		.opcode_i(read_execute_f_opcode_w),
		.dest_i(read_execute_f_dest_w),

		.dest_r4_o(dest_r4_w),
		.write_back_result_s4_o(write_back_result_s4_w),

		.dest_o(execute_f_write_back_dest_w),
		.write_back_result_o(execute_f_write_back_result_w)

	);



	//multiplexer that guides to WRITE_BACK stage the data from either execute or f_execute
	always_comb begin

		write_back_result_w = 0;
		write_back_dest_w = 0;
		stall_flag_w = 0;

		if ( ( (execute_f_write_back_dest_w != 0) || ( execute_f_write_back_result_w != 0 ) ) && ( (execute_write_back_dest_w == 0) || ( execute_write_back_result_w == 0 )  )  )
		//case when EX_f has result and EX_F has NOP
		begin

			write_back_result_w = execute_f_write_back_result_w;
			write_back_dest_w = execute_f_write_back_dest_w;


		end
		else if ( ( (execute_f_write_back_dest_w != 0) || ( execute_f_write_back_result_w != 0 ) ) && ( (execute_write_back_dest_w != 0) || ( execute_write_back_result_w != 0 )  )  )
		//case where both EX and EX_F have valid results, we will pick EX_F but also stall

		begin

			write_back_result_w = execute_f_write_back_result_w;
			write_back_dest_w = execute_f_write_back_dest_w;
			stall_flag_w = 1;

		end
		else if ( ( (execute_f_write_back_dest_w == 0) || ( execute_f_write_back_result_w == 0 ) ) && ( (execute_write_back_dest_w != 0) || ( execute_write_back_result_w != 0 )  )  )
		//case when EX_f has result and EX has NOP

		begin

			write_back_result_w = execute_write_back_result_w;
			write_back_dest_w = execute_write_back_dest_w;


		end

		else begin
			//both have NOPs
			write_back_result_w = 0;
			write_back_dest_w = 0;

		end

	end


	stage_wrtie_back write_back(

		.clk_i(clk_i),
		.rst_i(rst_i),		
		.data_in_i(data_in_i),

		.execute_result_i(write_back_result_w),
		.execute_dest_i(write_back_dest_w),
		.flags_i(processor_flags_w),


		.stall_flag_i(stall_flag_w),

		.write_reg_o(write_back_regs_wen_w),
		.dest_o(write_back_regs_dest_w),
		.result_o(write_back_regs_result_w)

	);


//block that does the data forwarding logic
	always_comb begin

		flag_forward_w = 0;
		data_forward_w = 0;

		//solving dependency between data_in and instruction in READ stage
		if( (read_execute_opcode_w==?`LOAD) && ( execute_write_back_dest_w == regs_src_1_w ) && (execute_write_back_dest_w !=0 ) ) begin
			flag_forward_w = 1;
			data_forward_w = data_in_i;
		end
		else if( (read_execute_opcode_w==?`LOAD) && ( execute_write_back_dest_w == regs_src_2_w ) && (execute_write_back_dest_w !=0 ) ) begin
			flag_forward_w = 2;
			data_forward_w = data_in_i;
		end


		//solving dependency between output of execute_f pipeline register and instruction in READ stage
		else if( ( execute_f_write_back_dest_w == regs_src_1_w ) && ( execute_f_write_back_dest_w != 0 ) ) begin
			flag_forward_w = 1;
			data_forward_w = execute_f_write_back_result_w;
		end
		else if( ( execute_f_write_back_dest_w == regs_src_2_w ) && ( execute_f_write_back_dest_w != 0 ) ) begin
			flag_forward_w = 2;
			data_forward_w = execute_f_write_back_result_w;
		end


		//solving dependency between output of execute pipeline register and instruction in READ stage
		else if( ( execute_write_back_dest_w == regs_src_1_w ) && (execute_write_back_dest_w !=0 ) ) begin
			flag_forward_w = 1;
			data_forward_w = execute_write_back_result_w;
		end
		else if( ( execute_write_back_dest_w == regs_src_2_w ) && (execute_write_back_dest_w !=0 ) ) begin
			flag_forward_w = 2;
			data_forward_w = execute_write_back_result_w;
		end


		//solving dependency between output of ALU in execute_f and instruction in READ stage
		else if( ( dest_r4_w == regs_src_1_w ) && ( dest_r4_w != 0 ) ) begin
			flag_forward_w = 1;
			data_forward_w = write_back_result_s4_w;
		end
		else if( ( dest_r4_w  == regs_src_2_w ) && ( dest_r4_w != 0 ) ) begin
			flag_forward_w = 2;
			data_forward_w = write_back_result_s4_w;
		end


		//solving dependency between output of ALU in execute and instruction in READ stage
		else if( ( dest_alu_w == regs_src_1_w ) && (dest_alu_w !=0 ) ) begin
			flag_forward_w = 1;
			data_forward_w = alu_result_w;
		end
		else if( ( dest_alu_w == regs_src_2_w ) && (dest_alu_w!=0 ) ) begin
			flag_forward_w = 2;
			data_forward_w = alu_result_w;
		end
		else begin

			flag_forward_w = 0;
			data_forward_w = 0;

		end


	end



endmodule





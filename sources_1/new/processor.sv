 /* main processor architecture file
  * it includes the 4 level pipeline structure: FETCH, READ, EXECUTE, WRITE BACK
  * proper design file
  *
  *
  */
 `include "D:/FACULTATE/MASTER AM/semestrul 1/DSD1/sursa/tema1/golden_model.srcs/sources_1/new/defines.vh"


module processor(

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

    logic regs_stop_w;
    logic regs_start_w;
    
    logic [2:0] dest_w;
    logic [2:0] execute_dest_w;
    
    logic [2:0] write_back_dest_w;
    
	logic [15:0] fetch_instruction_w;
	logic [15:0] read_instruction_w;

//TODO: add wire dimensions
	logic [`D_BITS-1:0] processor_result_w;
	logic [2:0] procesor_dest_w;

	logic [2:0] processor_src_1_w;
	logic [`D_BITS-1:0] processor_operand_1_w;

	logic [2:0] processor_src_2_w;
	logic [`D_BITS-1:0] processor_operand_2_w;
	
	logic [`D_BITS-1:0] data_1_w;
	logic [`D_BITS-1:0] data_2_w;
	logic [6:0] opcode_w;
	
	logic wen_w;

	stage_fetch fetch(
		// used for the ProgramCounter
		.rst_i(rst_i),   // active 0
		.clk_i(clk_i),
		.pc_o(pc_o),

		//used to receive the instruction
		.instruction_i(instruction_i),

		.fetch_instruction_o(fetch_instruction_w)
	);


	stage_read read(
	
	    .regs_stop_i(regs_stop_w),
	    .regs_start_o(regs_start_w),
	    
        .clk_i(clk_i),
        .rst_i(rst.i),
           
		.src_1_o(processor_src_1_w),
		.operand_1_i(processor_operand_1_w),


		.src_2_o(processor_src_2_w),
		.operand_2_i(processor_operand_2_w),

		.read_instruction_i(fetch_instruction_w),

        .dest_o(dest_w),
		.data_1_o(data_1_w),
		.data_2_o(data_2_w),
		.opcode_o(opcode_w)
	);

	//description of the REGS block

	regs REGS(
        .clk_i(clk_i),
        .rst_i(rst_i),
        
        .regs_stop_o(regs_stop_w),
        .regs_start_i(regs_start_w),
        
		.src_1_o(processor_src_1_w),
		.operand_1_i(processor_operand_1_w),

		.src_2_o(processor_src_2_w),
		.operand_2_i(processor_operand_2_w),        
        
        .wen_i(wen_w),
        .dest_i(write_back_dest_w),
        .result_i(result_w)

	);


	stage_execute execute(
        
        .rst_i(rst_i),
        .clk_i(clk_i),
        .data_1_i(data_1_w),
        .data_2_i(data_2_w),
        
        .opcode_i(opcode_w),
        .dest_i(dest_w),
        .dest_o(execute_dest_w),
        .write_back_result_o(),

		.address_o(address_o),
		.data_out_o(data_out_o)

	);

	stage_wrtie_back write_back(

		.write_o(),
		.dest_o(procesor_dest_s),
		.data_in_i(data_in_i),
		.result_o(processor_result_s)

	);


endmodule


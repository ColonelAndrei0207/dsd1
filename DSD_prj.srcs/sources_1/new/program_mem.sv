/*

 program memory file

 */


module program_mem (

		input logic clk_i,
		input logic rst_n_i,
		
		input logic we,
		input logic [`A_SIZE-1:0] instr_i,
		input logic [`A_BITS-1:0] instr_addr_i,
		output logic [`A_SIZE-1:0] instr_o

	);



	logic [ `A_SIZE-1 :0 ] gen_instr[`MEM_SIZE :0 ]; //declaration of the register array

    //sending instructions to the RISC
	always_ff @(posedge clk_i, negedge rst_n_i)  begin
        
        if(!rst_n_i) begin
        
            instr_o <=0;
        end
        else begin
		  instr_o <= gen_instr[instr_addr_i];
		end
		
	end

    //loading instructions into the memory from mem_ctrl
    always_ff @( posedge clk_i, negedge rst_n_i) begin
    
        if(!rst_n_i) begin
        
            gen_instr[instr_addr_i] <=0;
        end
        else begin
        
          if(we) begin
		      gen_instr[instr_addr_i] <= instr_i;
		  end
		end    
    
    end

/*
	//program instatiation
	always_comb begin

		gen_instr[0] = {`LOADC_I, `R0, 8'd15};
		gen_instr[1] = {`LOADC_I, `R1, 8'd5};
		gen_instr[2] = {`LOADC_I, `R2, 8'd8};
		gen_instr[3] = {`ADD, `R3, `R0, `R1};
		gen_instr[4] = {`STORE_I, `R2, 5'd0 , `R3};
		gen_instr[5] = {`ADDF, `R4, `R2, `R1};
		gen_instr[6] = {`JMP_I, 9'b0, `R2};
		gen_instr[7] = {`NOP};
		gen_instr[8] = { `JMPRC_I, `N, `R0, 6'd1  };
		gen_instr[9] = { `NOP };
		gen_instr[10] = {`SHIFTL, `R3, 6'd2 };
		gen_instr[11] = { `SHIFTRA, `R5, 6'd2 };
		gen_instr[12] = {`JMPC_I, `Z, `R7, 3'd0, `R0 };
		gen_instr[13] = {`HALT};
		gen_instr[14] = {`HALT};
		gen_instr[15] = {`LOAD_I, `R5, 5'd0, `R6};
		gen_instr[16] = {`HALT};
		
	end
*/	

endmodule   
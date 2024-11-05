 /******************************************************************************
  *
  * FILE DESCRIPTION: Define file with macros included in the design of the RISC processor
  *
  *******************************************************************************/

//1. MAIN PARAMETERS
 
 `define A_BITS 10 //data bus size
 `define D_BITS 32 //address bus size

//2. REGISTER SET
 
 `define R0 3'd0
 `define R1 3'd1
 `define R2 3'd2
 `define R3 3'd3
 `define R4 3'd4
 `define R5 3'd5
 `define R6 3'd6
 `define R7 3'd7
 
 //3. MEMORY
 
 `define MEMSIZE 2**`A_BITS


//4. INSTRUCTION SET; 22 in number; 4 in 4 bits; 3 in 5 bits; 13 in 7 bits and HALT and NOP that are blank
//these macros define the opcode associated with each instruction type

//NOP & HALT
 `define NOP 		7'b0000000
 `define HALT 		7'b1111111

//7 bits instructions
 `define ADD 		7'b0000001
 `define ADDF 		7'b0000010
 
 `define SUB 		7'b0000011 
 `define SUBF 		7'b0000100 
 
 `define AND 		7'b0000101 
 `define OR 		7'b0000110 
 `define XOR 		7'b0000111 
 
 `define NAND 		7'b0001000 
 `define NOR 		7'b0001001 
 `define NXOR 		7'b0001010  
 
 `define SHIFTR 	7'b0001011 
 `define SHIFTRA 	7'b0001100  
 `define SHIFTL 	7'b0001101 
 
 
//5 bits instruction
   
 `define LOAD 		5'b10001 
 `define LOADC 		5'b10010  
 `define STORE 		5'b10100  
 
//4 bits instructions

 `define JMP 		4'b1011 
 `define JMPR 		4'b1100  
 `define JMPC 		4'b1101 
 `define JMPRC 		4'b1110 

 
//5.1. conditional jump conditions

 `define N 	3'b000
 `define NN	3'b001
 `define Z 	3'b010
 `define NZ 3'b011
 

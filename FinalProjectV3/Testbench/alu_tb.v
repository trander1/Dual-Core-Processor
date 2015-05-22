`timescale 1ns / 10ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:28:52 02/12/2015
// Design Name:   top
// Module Name:   S:/Xilinx/Assignment2/top_tb.v
// Project Name:  Assignment2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module alu_tb;

parameter DATA_WIDTH = 8;
parameter OPCODE_LENGTH = 4;
parameter VECTOR_LENGTH = OPCODE_LENGTH + DATA_WIDTH + DATA_WIDTH;

	// Inputs
	reg [VECTOR_LENGTH-1:0] opcode_inputs;	
	reg reset;	
	reg clk;	

	// Outputs
	wire [DATA_WIDTH-1:0] final_output;
	wire carry_output, zero_flag;

	// Instantiate the Unit Under Test (UUT)
	alu alublock (
		.final_output(final_output), 
		.carry_output(carry_output), 
		.zero_flag(zero_flag), 
		.opcode_inputs(opcode_inputs),
		.reset_in(reset),
		.clk(clk)
	);

	initial begin
		// Initialize Inputs
//		opcode_inputs = 0;		
		reset =1;
		clk=1;
		// Wait 100 ns for global reset to finish
		#2 reset = 0; opcode_inputs = 20'b0001_1111_1111_0000_0001;		// ADD
//		#4 opcode_inputs = 36'b0011_1001_0000_0101_0101_1000_0000_0000_0001;		// MULT
//		#12 opcode_inputs = 36'b0010_0000_0000_0000_1110_0111_1111_1111_1111;		// SUBTRACT			
//		#4 opcode_inputs = 36'b1001_0000_0000_0000_0000_0000_0000_0000_0000;		// ZERO TEST
//		#1 opcode_inputs = 36'b1100_0000_0010_0000_0000_0000_0001_1111_1111;		// LESS THAN
//		#2 opcode_inputs = 36'b1010_0000_0010_0000_0000_0000_0001_1111_1111;		// GREATER THAN
//		#2 opcode_inputs = 36'b0110_0000_0010_0000_0000_0000_0001_1111_1111;		// AND
//		#1 opcode_inputs = 36'b0111_0000_0010_0000_0000_0000_0001_1111_1111;		// OR
//		#2 opcode_inputs = 36'b1011_0000_0010_0000_0000_0000_0001_1111_1111;		// EQUAL
// 	#2 opcode_inputs = 36'b0100_1000_0000_0000_0000_0000_0000_0000_0000;		// DIVIDE
		#4 $finish;
		// Add stimulus here

	end
	
	always begin
		#1 clk = ~clk; // Toggle clock every 1 ticks
	end
endmodule

